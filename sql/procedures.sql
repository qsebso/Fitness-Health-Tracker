-- Used for: Stored procedures, functions, triggers, and related server-side logic.
-- Information inside: Executable procedures; upserts use INSERT ... VALUES (...) AS new (MySQL 8.0.19+), not VALUES().
use fitness_db;
DROP PROCEDURE IF EXISTS sp_register_user;
DROP PROCEDURE IF EXISTS sp_upsert_daily_metric;
DROP PROCEDURE IF EXISTS sp_upsert_daily_checkin;
DROP PROCEDURE IF EXISTS sp_log_nutrition_entry;
DROP TRIGGER IF EXISTS tr_users_before_insert_dob;
DROP TRIGGER IF EXISTS tr_users_before_update_dob;

-- =============================================================================
-- TRIGGERS — users.date_of_birth not in the future (must match schema.sql)
-- =============================================================================
DELIMITER $$

CREATE TRIGGER tr_users_before_insert_dob
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'date_of_birth cannot be in the future.';
    END IF;
END$$

CREATE TRIGGER tr_users_before_update_dob
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'date_of_birth cannot be in the future.';
    END IF;
END$$

DELIMITER ;

-- =============================================================================
-- STORED PROCEDURES — app-facing workflows (parameterize user_id, dates, limits)
-- =============================================================================

-- sp_register_user (or create_user)
--   What: Insert a new row in users with required fields (password_hash supplied by app after hashing).
--   Why: One place for column lists and defaults; easier to extend validation or audit logging later.
DELIMITER $$

CREATE PROCEDURE sp_register_user(
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password_hash VARCHAR(255)
)
BEGIN
    INSERT INTO users (username, email, password_hash)
    VALUES (p_username, p_email, p_password_hash);
END $$
DELIMITER ;

-- sp_upsert_daily_metric
--   What: INSERT a daily_metrics row or UPDATE the existing row for the same (user_id, record_date).
--   Why: Enforces “one metric row per user per day” without the app duplicating ON DUPLICATE KEY UPDATE logic.
DELIMITER $$

CREATE PROCEDURE sp_upsert_daily_metric(
    IN p_user_id INT,
    IN p_record_date DATE,
    IN p_weight_lbs DECIMAL(5,2),
    IN p_steps INT,
    IN p_sleep_hours DECIMAL(5,2),
    IN p_water_intake_cups DECIMAL(5,2)
)
BEGIN
    INSERT INTO daily_metrics (user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups)
    VALUES (p_user_id, p_record_date, p_weight_lbs, p_steps, p_sleep_hours, p_water_intake_cups) AS new
    ON DUPLICATE KEY UPDATE
        weight_lbs = new.weight_lbs,
        steps = new.steps,
        sleep_hours = new.sleep_hours,
        water_intake_cups = new.water_intake_cups;
END $$
DELIMITER ;

-- sp_upsert_daily_checkin
--   What: INSERT or UPDATE daily_checkins for (user_id, record_date).
--   Why: Same pattern as daily_metrics; respects unique_checkin_per_day.
DELIMITER $$

CREATE PROCEDURE sp_upsert_daily_checkin(
    IN p_user_id INT,
    IN p_record_date DATE,
    IN p_eating_quality ENUM('poor', 'average', 'good'),
    IN p_energy_level ENUM('low', 'medium', 'high'),
    IN p_adherence_to_plan ENUM('poor', 'average', 'good'),
    IN p_notes TEXT
)
BEGIN
    INSERT INTO daily_checkins (user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes)
    VALUES (p_user_id, p_record_date, p_eating_quality, p_energy_level, p_adherence_to_plan, p_notes) AS new
    ON DUPLICATE KEY UPDATE
        eating_quality = new.eating_quality,
        energy_level = new.energy_level,
        adherence_to_plan = new.adherence_to_plan,
        notes = new.notes;
END $$
DELIMITER ;

-- sp_log_nutrition_entry
--   What: INSERT into nutrition_logs for a user (meal, food, macros, optional log_date override).
--   Why: Encapsulates logging rules (e.g., default TIMESTAMP, future validation).
DELIMITER $$

CREATE PROCEDURE sp_log_nutrition_entry(
    IN p_user_id INT,
    IN p_log_date TIMESTAMP,
    IN p_meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack'),
    IN p_food_item VARCHAR(255),
    IN p_calories INT,
    IN p_protein_g DECIMAL(6,2),
    IN p_carbs_g DECIMAL(6,2),
    IN p_fat_g DECIMAL(6,2)
)
BEGIN
    INSERT INTO nutrition_logs (user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g)
    VALUES (p_user_id, p_log_date, p_meal_type, p_food_item, p_calories, p_protein_g, p_carbs_g, p_fat_g);
END $$
DELIMITER ;

-- sp_log_workout
--   What: INSERT into workout_logs; optionally accept precomputed calories_burned or leave it for a trigger/function.
--   Why: Keeps workout logging consistent and can call shared calorie logic in one path.

-- sp_create_goal / sp_update_goal_status
--   What: INSERT goals; UPDATE status, end_date, or target_value for an existing goal owned by the user.
--   Why: Centralizes transitions (e.g., active → completed) and ownership checks in one routine.

-- sp_insert_achievement
--   What: INSERT into achievements (title, description) for a user, optionally with achieved_at.
--   Why: Single entry point if you later add deduplication rules or notifications.

-- sp_refresh_progress_snapshot (single user + snapshot_date)
--   What: Compute 7-day rolling aggregates and INSERT or UPDATE progress_snapshots for that user and snapshot_date
--         (avg weight/steps/sleep from daily_metrics; workout count from workout_logs; avg protein from nutrition_logs over the window).
--   Why: progress_snapshots is derived data; a procedure keeps heavy aggregation off the app and matches unique_snapshot_per_day.

-- sp_refresh_progress_snapshots_for_date (all users, one snapshot_date)
--   What: Loop or set-based refresh of progress_snapshots for every user for a given date (e.g., nightly job).
--   Why: Batch maintenance for dashboards without per-request aggregation.

-- sp_get_user_dashboard (optional)
--   What: Return one or more result sets: profile summary, latest daily_metric, active goals, recent workouts, etc.
--   Why: Optional convenience to reduce round trips; only if your stack benefits from a DB-centric API.

-- sp_create_support_group
--   What: Create a row in support_groups and assign the creator as the owner in group_memberships.
--   Why: Keeps support group creation + owner assignment atomic for many-to-many integrity.

-- sp_add_group_member
--   What: Add a user to a support group with role = member (or provided role if allowed).
--   Why: Centralizes duplicate checks and permission rules for membership creation.

-- sp_remove_group_member
--   What: Remove a user from group_memberships for a given group.
--   Why: Enforces membership-removal rules in one place (e.g., owner-transfer guardrails later).

-- sp_get_group_members
--   What: Return member rows for a group by joining group_memberships to users.
--   Why: Common query for group detail pages and collaboration views.

-- sp_get_user_groups
--   What: Return groups that a user belongs to by joining group_memberships to support_groups.
--   Why: Common query for listing all groups tied to a user account.

-- =============================================================================
-- FUNCTIONS — reusable scalar or table expressions (MySQL: deterministic rules apply)
-- =============================================================================

-- fn_calories_burned_from_exercise (duration_minutes, calories_per_hour)
--   What: Return estimated calories (e.g., duration/60 * calories_per_hour) with consistent rounding.
--   Why: Same formula everywhere for workout_logs and reporting; callable from triggers and procedures.

-- fn_age_from_dob (date_of_birth, as_of_date)
--   What: Return age in years for display or eligibility checks.
--   Why: Avoid duplicating date math in SQL and app code.

-- fn_bmi_from_weight_height (weight_lbs, height_inches) — optional
--   What: Return BMI from weight and users.height_inches.
--   Why: Reporting and goal progress without storing redundant BMI on every row.

-- =============================================================================
-- TRIGGERS — automatic consistency when rows change
-- =============================================================================

-- tr_workout_logs_before_insert / tr_workout_logs_before_update
--   What: If calories_burned IS NULL, set it using exercise_types.calories_per_hour and duration_minutes (via fn_calories_burned_from_exercise or inline).
--   Why: Keeps calorie estimates consistent when the app omits the column.

-- tr_goals_before_insert / tr_goals_before_update (optional, if not fully covered by CHECK)
--   What: Reject or adjust rows where end_date is not NULL and end_date <= start_date.
--   Why: Defense in depth if constraints are ever relaxed or loaded from bulk import.

-- tr_after_daily_metrics_change (optional)
--   What: AFTER INSERT/UPDATE on daily_metrics, call sp_refresh_progress_snapshot for that user and record_date (or queue a refresh).
--   Why: Keeps progress_snapshots in sync; use with care—can be expensive; batch jobs are often preferred.

-- tr_after_workout_or_nutrition_change (optional)
--   What: AFTER INSERT/UPDATE on workout_logs or nutrition_logs, refresh snapshot for affected user/date.
--   Why: Same as above for metrics that feed 7-day aggregates; often replaced by a scheduled job for performance.

-- =============================================================================
-- EVENTS (MySQL EVENT scheduler) — optional, not strictly “procedures” but same script is fine
-- =============================================================================

-- evt_daily_refresh_progress_snapshots
--   What: Once per day, run sp_refresh_progress_snapshots_for_date for yesterday (or “today” depending on timezone rules).
--   Why: Offloads snapshot maintenance from user traffic and avoids trigger storms.

-- =============================================================================
-- NOTES
-- =============================================================================
-- - Password verification belongs in the application layer; the DB should only store password_hash.
-- - Prefer CHECK constraints and FKs (already in schema.sql) for static rules; use procedures/triggers for cross-row or derived logic.
-- - If snapshots are refreshed rarely, skip per-row triggers and rely on EVENT + manual sp_refresh_* after bulk imports.
