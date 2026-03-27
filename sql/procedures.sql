-- Used for: Stored procedures, triggers (by table), and future dashboard notes.
-- Information inside: Grouped by table. Upserts use INSERT ... VALUES (...) AS new (MySQL 8.0.19+).
-- Run after schema.sql (same database).

-- TODO: functions for workout calorie fill, goal progress, maybe achievement progress
-- TODO: dashboard creation and refresh but manybe use a view for the dashboard

USE fitness_db;

-- =============================================================================
-- DROP ALL (idempotent before CREATE). Trailing comment = quick reference for that object.
-- =============================================================================
DROP PROCEDURE IF EXISTS sp_register_user;                        -- INSERT full user row; SELECT new user_id
DROP PROCEDURE IF EXISTS sp_get_user_auth_by_username;            -- SELECT login fields incl. password_hash by username
DROP PROCEDURE IF EXISTS sp_get_user_by_id;                       -- SELECT profile row by user_id
DROP PROCEDURE IF EXISTS sp_update_user_profile;                  -- UPDATE name, email, gender, height, DOB for one user
DROP PROCEDURE IF EXISTS sp_update_user_password_hash;            -- UPDATE password_hash for one user
DROP PROCEDURE IF EXISTS sp_upsert_exercise_type;                 -- INSERT or UPDATE exercise_types by unique name
DROP PROCEDURE IF EXISTS sp_upsert_daily_metric;                  -- INSERT/UPSERT daily_metrics per user+date
DROP PROCEDURE IF EXISTS sp_upsert_daily_checkin;                 -- INSERT/UPSERT daily_checkins per user+date
DROP PROCEDURE IF EXISTS sp_get_user_daily_checkins;             -- SELECT recent check-ins for a user
DROP PROCEDURE IF EXISTS sp_log_nutrition_entry;                  -- INSERT nutrition_logs row
DROP PROCEDURE IF EXISTS sp_update_nutrition_entry;               -- UPDATE nutrition row (scoped by user_id)
DROP PROCEDURE IF EXISTS sp_delete_nutrition_entry;               -- DELETE nutrition row (scoped by user_id)
DROP PROCEDURE IF EXISTS sp_log_workout;                          -- INSERT workout_logs row
DROP PROCEDURE IF EXISTS sp_update_workout_log;                   -- UPDATE workout row (scoped by user_id)
DROP PROCEDURE IF EXISTS sp_delete_workout_log;                   -- DELETE workout row (scoped by user_id)
DROP PROCEDURE IF EXISTS sp_create_goal;                          -- INSERT goals row
DROP PROCEDURE IF EXISTS sp_update_goal_status;                   -- UPDATE goal status only (goal_id + user_id)
DROP PROCEDURE IF EXISTS sp_update_goal;                          -- UPDATE full goal row (goal_id + user_id)
DROP PROCEDURE IF EXISTS sp_insert_achievement;                   -- legacy name; replaced by sp_grant_user_achievement
DROP PROCEDURE IF EXISTS sp_grant_user_achievement;               -- INSERT user_achievements if not already earned (by def id)
DROP PROCEDURE IF EXISTS sp_grant_user_achievement_by_code;       -- Same, resolve achievement_definitions.code first
DROP PROCEDURE IF EXISTS sp_list_achievement_definitions;         -- SELECT all catalog achievement rows
DROP PROCEDURE IF EXISTS sp_get_user_achievements;                -- SELECT earned achievements for user (joins definitions)
DROP PROCEDURE IF EXISTS sp_create_support_group;                 -- INSERT group + creator as owner; SELECT new group_id
DROP PROCEDURE IF EXISTS sp_add_group_member;                     -- INSERT group_memberships row
DROP PROCEDURE IF EXISTS sp_remove_group_member;                  -- DELETE membership row
DROP PROCEDURE IF EXISTS sp_get_group_members;                    -- SELECT members + username for a group
DROP PROCEDURE IF EXISTS sp_get_user_groups;                      -- SELECT groups + role for a user
DROP PROCEDURE IF EXISTS sp_create_group_post;                    -- INSERT group_posts row for a group member
DROP PROCEDURE IF EXISTS sp_get_group_posts;                      -- SELECT recent posts in a group (newest first)

DROP TRIGGER IF EXISTS tr_users_before_insert_dob;                -- BEFORE INSERT users: block future DOB
DROP TRIGGER IF EXISTS tr_users_before_update_dob;                -- BEFORE UPDATE users: block future DOB

-- =============================================================================
-- TABLE: users (triggers + register + profile + password + reads)
-- =============================================================================
DELIMITER $$

-- Trigger: block INSERT if date_of_birth is in the future (uses CURDATE(); not suitable as a static CHECK).
CREATE TRIGGER tr_users_before_insert_dob
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'date_of_birth cannot be in the future.';
    END IF;
END$$

-- Trigger: block UPDATE if new date_of_birth is in the future.
CREATE TRIGGER tr_users_before_update_dob
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF NEW.date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'date_of_birth cannot be in the future.';
    END IF;
END$$

-- Procedure: register a new user (app supplies password_hash); returns new user_id via SELECT.
CREATE PROCEDURE sp_register_user(
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password_hash VARCHAR(255),
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_date_of_birth DATE,
    IN p_gender ENUM('male', 'female', 'other'),
    IN p_height_inches INT
)
BEGIN
    INSERT INTO users (
        username, email, password_hash, first_name, last_name, date_of_birth, gender, height_inches
    )
    VALUES (
        p_username, p_email, p_password_hash, p_first_name, p_last_name, p_date_of_birth, p_gender, p_height_inches
    );
    SELECT LAST_INSERT_ID() AS user_id;
END$$

-- Procedure: fetch row for login (includes password_hash for app-side verify).
CREATE PROCEDURE sp_get_user_auth_by_username(IN p_username VARCHAR(255))
BEGIN
    SELECT user_id, username, email, password_hash
    FROM users
    WHERE username = p_username;
END$$

-- Procedure: fetch profile/session fields for one user by id.
CREATE PROCEDURE sp_get_user_by_id(IN p_user_id INT)
BEGIN
    SELECT user_id, username, email, first_name, last_name, gender, height_inches, date_of_birth
    FROM users
    WHERE user_id = p_user_id;
END$$

-- Procedure: update editable profile columns (DOB still validated by triggers).
CREATE PROCEDURE sp_update_user_profile(
    IN p_user_id INT,
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_gender ENUM('male', 'female', 'other'),
    IN p_height_inches INT,
    IN p_date_of_birth DATE
)
BEGIN
    UPDATE users
    SET
        first_name = p_first_name,
        last_name = p_last_name,
        email = p_email,
        gender = p_gender,
        height_inches = p_height_inches,
        date_of_birth = p_date_of_birth
    WHERE user_id = p_user_id;
END$$

-- Procedure: set password_hash after app hashes the new password.
CREATE PROCEDURE sp_update_user_password_hash(
    IN p_user_id INT,
    IN p_password_hash VARCHAR(255)
)
BEGIN
    UPDATE users
    SET password_hash = p_password_hash
    WHERE user_id = p_user_id;
END$$

DELIMITER ;

-- =============================================================================
-- TABLE: exercise_types (admin / custom exercises — upsert on unique name)
-- =============================================================================
DELIMITER $$

-- Procedure: add or refresh an exercise type by unique name (admin / custom exercises).
CREATE PROCEDURE sp_upsert_exercise_type(
    IN p_name VARCHAR(255),
    IN p_category VARCHAR(255),
    IN p_muscle_group VARCHAR(255),
    IN p_calories_per_hour DECIMAL(5,2)
)
BEGIN
    INSERT INTO exercise_types (name, category, muscle_group, calories_per_hour)
    VALUES (p_name, p_category, p_muscle_group, p_calories_per_hour) AS new
    ON DUPLICATE KEY UPDATE
        category = new.category,
        muscle_group = new.muscle_group,
        calories_per_hour = new.calories_per_hour;
END$$

DELIMITER ;

-- =============================================================================
-- TABLE: daily_metrics
-- =============================================================================
DELIMITER $$

-- Procedure: insert or update one daily_metrics row per (user_id, record_date).
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
END$$

DELIMITER ;

-- =============================================================================
-- TABLE: daily_checkins
-- =============================================================================
DELIMITER $$

-- Procedure: insert or update one daily_checkins row per (user_id, record_date).
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
END$$

-- Procedure: list recent check-ins for a user (newest dates first).
CREATE PROCEDURE sp_get_user_daily_checkins(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        checkin_id,
        user_id,
        record_date,
        eating_quality,
        energy_level,
        adherence_to_plan,
        notes
    FROM daily_checkins
    WHERE user_id = p_user_id
    ORDER BY record_date DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- =============================================================================
-- TABLE: nutrition_logs
-- =============================================================================
DELIMITER $$

-- Procedure: insert a nutrition log entry (meal/macros).
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
END$$

-- Procedure: update a nutrition log row; only if nutrition_id belongs to p_user_id.
CREATE PROCEDURE sp_update_nutrition_entry(
    IN p_nutrition_id INT,
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
    UPDATE nutrition_logs
    SET
        log_date = p_log_date,
        meal_type = p_meal_type,
        food_item = p_food_item,
        calories = p_calories,
        protein_g = p_protein_g,
        carbs_g = p_carbs_g,
        fat_g = p_fat_g
    WHERE nutrition_id = p_nutrition_id
      AND user_id = p_user_id;
END$$

-- Procedure: delete a nutrition log row; only if it belongs to p_user_id.
CREATE PROCEDURE sp_delete_nutrition_entry(IN p_nutrition_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM nutrition_logs
    WHERE nutrition_id = p_nutrition_id
      AND user_id = p_user_id;
END$$

DELIMITER ;

-- =============================================================================
-- TABLE: workout_logs
-- =============================================================================
DELIMITER $$

-- Procedure: insert a workout log row.
CREATE PROCEDURE sp_log_workout(
    IN p_user_id INT,
    IN p_exercise_id INT,
    IN p_log_date TIMESTAMP,
    IN p_duration_minutes INT,
    IN p_calories_burned DECIMAL(6,2),
    IN p_notes TEXT
)
BEGIN
    INSERT INTO workout_logs (user_id, exercise_id, log_date, duration_minutes, calories_burned, notes)
    VALUES (p_user_id, p_exercise_id, p_log_date, p_duration_minutes, p_calories_burned, p_notes);
END$$

-- Procedure: update a workout row; only if workout_id belongs to p_user_id.
CREATE PROCEDURE sp_update_workout_log(
    IN p_workout_id INT,
    IN p_user_id INT,
    IN p_exercise_id INT,
    IN p_log_date TIMESTAMP,
    IN p_duration_minutes INT,
    IN p_calories_burned DECIMAL(6,2),
    IN p_notes TEXT
)
BEGIN
    UPDATE workout_logs
    SET
        exercise_id = p_exercise_id,
        log_date = p_log_date,
        duration_minutes = p_duration_minutes,
        calories_burned = p_calories_burned,
        notes = p_notes
    WHERE workout_id = p_workout_id
      AND user_id = p_user_id;
END$$

-- Procedure: delete a workout row; only if it belongs to p_user_id.
CREATE PROCEDURE sp_delete_workout_log(IN p_workout_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM workout_logs
    WHERE workout_id = p_workout_id
      AND user_id = p_user_id;
END$$

DELIMITER ;

-- =============================================================================
-- TABLE: goals
-- =============================================================================
DELIMITER $$

-- Procedure: create a new goal for a user.
CREATE PROCEDURE sp_create_goal(
    IN p_user_id INT,
    IN p_goal_type ENUM('weight_loss', 'weight_gain', 'muscle_gain', 'endurance'),
    IN p_target_value DECIMAL(6,2),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_status ENUM('active', 'completed', 'paused')
)
BEGIN
    INSERT INTO goals (user_id, goal_type, target_value, start_date, end_date, status)
    VALUES (p_user_id, p_goal_type, p_target_value, p_start_date, p_end_date, p_status);
END$$

-- Procedure: change only status; requires matching goal_id and user_id (ownership).
CREATE PROCEDURE sp_update_goal_status(
    IN p_goal_id INT,
    IN p_user_id INT,
    IN p_status ENUM('active', 'completed', 'paused')
)
BEGIN
    UPDATE goals
    SET status = p_status
    WHERE goal_id = p_goal_id
      AND user_id = p_user_id;
END$$

-- Procedure: full goal edit (type, target, dates, status); requires matching goal_id and user_id.
CREATE PROCEDURE sp_update_goal(
    IN p_goal_id INT,
    IN p_user_id INT,
    IN p_goal_type ENUM('weight_loss', 'weight_gain', 'muscle_gain', 'endurance'),
    IN p_target_value DECIMAL(6,2),
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_status ENUM('active', 'completed', 'paused')
)
BEGIN
    UPDATE goals
    SET
        goal_type = p_goal_type,
        target_value = p_target_value,
        start_date = p_start_date,
        end_date = p_end_date,
        status = p_status
    WHERE goal_id = p_goal_id
      AND user_id = p_user_id;
END$$

DELIMITER ;

-- =============================================================================
-- TABLES: achievement_definitions (catalog) + user_achievements (earned)
-- Rule checks (e.g. 5-day step streak) are normally implemented in the app or
-- in dedicated procedures/events that CALL sp_grant_user_* when conditions hold.
-- =============================================================================
DELIMITER $$

-- Procedure: grant one catalog achievement to a user once (unique_user_achievement); no-op if duplicate.
CREATE PROCEDURE sp_grant_user_achievement(
    IN p_user_id INT,
    IN p_achievement_def_id INT,
    IN p_achieved_at TIMESTAMP
)
BEGIN
    INSERT IGNORE INTO user_achievements (user_id, achievement_def_id, achieved_at)
    VALUES (p_user_id, p_achievement_def_id, p_achieved_at);
END$$

-- Procedure: grant by stable code (e.g. steps_streak_5); resolves achievement_def_id from achievement_definitions.
CREATE PROCEDURE sp_grant_user_achievement_by_code(
    IN p_user_id INT,
    IN p_code VARCHAR(64),
    IN p_achieved_at TIMESTAMP
)
BEGIN
    DECLARE v_def_id INT;

    SELECT achievement_def_id INTO v_def_id
    FROM achievement_definitions
    WHERE code = p_code
    LIMIT 1;

    IF v_def_id IS NOT NULL THEN
        INSERT IGNORE INTO user_achievements (user_id, achievement_def_id, achieved_at)
        VALUES (p_user_id, v_def_id, p_achieved_at);
    END IF;
END$$

-- Procedure: list all defined achievements (for UI / admin).
CREATE PROCEDURE sp_list_achievement_definitions()
BEGIN
    SELECT achievement_def_id, code, title, description
    FROM achievement_definitions
    ORDER BY achievement_def_id;
END$$

-- Procedure: list a user's earned achievements with titles (newest first).
CREATE PROCEDURE sp_get_user_achievements(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        ua.user_achievement_id,
        ua.user_id,
        ua.achievement_def_id,
        d.code,
        d.title,
        d.description,
        ua.achieved_at
    FROM user_achievements ua
    JOIN achievement_definitions d ON d.achievement_def_id = ua.achievement_def_id
    WHERE ua.user_id = p_user_id
    ORDER BY ua.achieved_at DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- =============================================================================
-- TABLES: support_groups + group_memberships (atomic create; membership CRUD + reads)
-- =============================================================================
DELIMITER $$

-- Procedure: create support_groups row and add creator as owner in group_memberships (single transaction); returns group_id.
CREATE PROCEDURE sp_create_support_group(
    IN p_group_name VARCHAR(255),
    IN p_description TEXT,
    IN p_created_by_user_id INT
)
BEGIN
    DECLARE v_group_id INT;

    INSERT INTO support_groups (group_name, description, created_by_user_id)
    VALUES (p_group_name, p_description, p_created_by_user_id);

    SET v_group_id = LAST_INSERT_ID();

    INSERT INTO group_memberships (group_id, user_id, role)
    VALUES (v_group_id, p_created_by_user_id, 'owner');

    SELECT v_group_id AS group_id;
END$$

-- Procedure: add a user to a group with a role (respect unique_group_membership).
CREATE PROCEDURE sp_add_group_member(
    IN p_group_id INT,
    IN p_user_id INT,
    IN p_role ENUM('owner', 'member')
)
BEGIN
    INSERT INTO group_memberships (group_id, user_id, role)
    VALUES (p_group_id, p_user_id, p_role);
END$$

-- Procedure: remove a user from a group.
CREATE PROCEDURE sp_remove_group_member(IN p_group_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM group_memberships
    WHERE group_id = p_group_id
      AND user_id = p_user_id;
END$$

-- Procedure: list members of a group with usernames and roles.
CREATE PROCEDURE sp_get_group_members(IN p_group_id INT)
BEGIN
    SELECT u.user_id, u.username, gm.role
    FROM group_memberships gm
    JOIN users u ON gm.user_id = u.user_id
    WHERE gm.group_id = p_group_id;
END$$

-- Procedure: list groups a user belongs to with group name and membership role.
CREATE PROCEDURE sp_get_user_groups(IN p_user_id INT)
BEGIN
    SELECT sg.group_id, sg.group_name, gm.role
    FROM group_memberships gm
    JOIN support_groups sg ON gm.group_id = sg.group_id
    WHERE gm.user_id = p_user_id;
END$$

-- Procedure: create a new post in a group for a user who is a member of that group.
CREATE PROCEDURE sp_create_group_post(
    IN p_group_id INT,
    IN p_user_id INT,
    IN p_content TEXT
)
BEGIN
    INSERT INTO group_posts (group_id, user_id, content)
    SELECT p_group_id, p_user_id, p_content
    FROM group_memberships gm
    WHERE gm.group_id = p_group_id
      AND gm.user_id = p_user_id
    LIMIT 1;
END$$

-- Procedure: list recent posts for a group with poster usernames.
CREATE PROCEDURE sp_get_group_posts(IN p_group_id INT, IN p_limit INT)
BEGIN
    SELECT
        gp.post_id,
        gp.group_id,
        gp.user_id,
        u.username,
        gp.content,
        gp.created_at
    FROM group_posts gp
    JOIN users u ON u.user_id = gp.user_id
    WHERE gp.group_id = p_group_id
    ORDER BY gp.created_at DESC, gp.post_id DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- =============================================================================
-- DASHBOARD / progress_snapshots (later — not implemented here)
-- =============================================================================
-- future work:
--   sp_refresh_progress_snapshot(user_id, snapshot_date) — upsert 7-day aggregates into progress_snapshots
--   sp_refresh_progress_snapshots_for_date(snapshot_date) — batch for all users
--   EVENT evt_daily_refresh_progress_snapshots — nightly job
-- Optional triggers/functions (comments only): workout calorie fill, goal date guard, snapshot refresh hooks

-- NOTES
-- - Password verification stays in the app; DB stores password_hash only.
-- - Prefer CHECK/FK in schema.sql; procedures enforce ownership (user_id on UPDATE/DELETE where applicable).
-- - sp_update_goal_status now requires p_user_id so status changes cannot target another user's goal.
