-- Used for: Stored procedures, functions, triggers, and related server-side logic.
-- Information inside: Roadmap only (comments). Implement when you need reusable or enforced behavior.

-- =============================================================================
-- STORED PROCEDURES — app-facing workflows (parameterize user_id, dates, limits)
-- =============================================================================

-- sp_register_user (or create_user)
--   What: Insert a new row in users with required fields (password_hash supplied by app after hashing).
--   Why: One place for column lists and defaults; easier to extend validation or audit logging later.

-- sp_upsert_daily_metric
--   What: INSERT a daily_metrics row or UPDATE the existing row for the same (user_id, record_date).
--   Why: Enforces “one metric row per user per day” without the app duplicating ON DUPLICATE KEY UPDATE logic.

-- sp_upsert_daily_checkin
--   What: INSERT or UPDATE daily_checkins for (user_id, record_date).
--   Why: Same pattern as daily_metrics; respects unique_checkin_per_day.

-- sp_log_nutrition_entry
--   What: INSERT into nutrition_logs for a user (meal, food, macros, optional log_date override).
--   Why: Encapsulates logging rules (e.g., default TIMESTAMP, future validation).

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
