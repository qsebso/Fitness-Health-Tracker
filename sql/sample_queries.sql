-- Used for: Example SQL for documentation and manual testing.
-- Information inside: CALLs for procedures in procedures.sql (plus verification SELECTs and expected outcomes).
--
-- Prereqs: run schema.sql, then seed.sql, then procedures.sql (same database as `USE` below).
-- Database name matches sql/schema.sql (change USE if your config differs).

USE fitness_db;

-- =============================================================================
-- 1) sp_upsert_daily_checkin — insert new row (user_id + record_date not in seed)
-- =============================================================================
-- Seed has user_id=1 check-in on 2026-03-14 only. Use a fresh date so this is a true INSERT.

CALL sp_upsert_daily_checkin(
    1,
    '2026-03-17',
    'good',
    'high',
    'good',
    'Procedure test: first insert for this date.'
);

-- EXPECTED: procedure completes with no error; exactly one new row for (user_id=1, record_date='2026-03-17').

SELECT checkin_id, user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes
FROM daily_checkins
WHERE user_id = 1 AND record_date = '2026-03-17';

-- EXPECTED: 1 row.
--   eating_quality = 'good', energy_level = 'high', adherence_to_plan = 'good'
--   notes contains 'Procedure test: first insert'

-- =============================================================================
-- 2) sp_upsert_daily_checkin — update same (user_id, record_date) via ON DUPLICATE KEY
-- =============================================================================

CALL sp_upsert_daily_checkin(
    1,
    '2026-03-17',
    'average',
    'medium',
    'average',
    'Procedure test: upsert should UPDATE same row.'
);

-- EXPECTED: still exactly one row for (1, '2026-03-17'); enums and notes changed.

SELECT checkin_id, user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes
FROM daily_checkins
WHERE user_id = 1 AND record_date = '2026-03-17';

-- EXPECTED: 1 row.
--   eating_quality = 'average', energy_level = 'medium', adherence_to_plan = 'average'
--   notes = 'Procedure test: upsert should UPDATE same row.'

-- =============================================================================
-- 3) sp_upsert_daily_checkin — overlap with seed row (optional: proves upsert on existing seed date)
-- =============================================================================

CALL sp_upsert_daily_checkin(
    1,
    '2026-03-14',
    'good',
    'high',
    'good',
    'Overwritten via procedure from seed row.'
);

-- EXPECTED: no duplicate key error; row for (1,'2026-03-14') is updated, not inserted twice.

SELECT eating_quality, energy_level, adherence_to_plan, notes
FROM daily_checkins
WHERE user_id = 1 AND record_date = '2026-03-14';

-- EXPECTED: 1 row; notes = 'Overwritten via procedure from seed row.' (other columns as passed above)

-- =============================================================================
-- 4) sp_upsert_daily_metric — insert / upsert (same pattern as check-ins)
-- =============================================================================
-- Seed already has metrics for user 1 on 2026-03-14 and 2026-03-15. Use 2026-03-17 for a clean insert.

CALL sp_upsert_daily_metric(1, '2026-03-17', 181.50, 11000, 7.25, 9.50);

-- EXPECTED: new daily_metrics row for (user_id=1, record_date='2026-03-17').

SELECT metric_id, user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups
FROM daily_metrics
WHERE user_id = 1 AND record_date = '2026-03-17';

-- EXPECTED: 1 row with weight_lbs=181.50, steps=11000, sleep_hours=7.25, water_intake_cups=9.50

CALL sp_upsert_daily_metric(1, '2026-03-17', 181.00, 11500, 8.00, 10.00);

-- EXPECTED: same row updated (still one row per unique user_id + record_date).

SELECT weight_lbs, steps, sleep_hours, water_intake_cups
FROM daily_metrics
WHERE user_id = 1 AND record_date = '2026-03-17';

-- EXPECTED: weight_lbs=181.00, steps=11500, sleep_hours=8.00, water_intake_cups=10.00

-- =============================================================================
-- 5) sp_log_nutrition_entry — insert a meal row
-- =============================================================================

CALL sp_log_nutrition_entry(
    1,
    '2026-03-17 12:30:00',
    'lunch',
    'Procedure test meal',
    550,
    35.00,
    55.00,
    18.00
);

-- EXPECTED: one new row in nutrition_logs for user_id=1 with given meal_type and macros.

SELECT nutrition_id, user_id, meal_type, food_item, calories, protein_g, carbs_g, fat_g, log_date
FROM nutrition_logs
WHERE user_id = 1 AND food_item = 'Procedure test meal'
ORDER BY nutrition_id DESC
LIMIT 1;

-- EXPECTED: 1 row; calories=550, protein_g=35, carbs_g=55, fat_g=18 (log_date may show as stored TIMESTAMP)

-- =============================================================================
-- 6) sp_register_user — NOTE vs current schema (read before running)
-- =============================================================================
-- procedures.sql currently inserts only (username, email, password_hash).
-- sql/schema.sql requires NOT NULL: first_name, last_name, date_of_birth, gender, height_inches.
--
-- EXPECTED if you run as-is: MySQL error (e.g. Field 'first_name' doesn't have a default value).
-- Fix: extend sp_register_user to supply all required columns, then test with:
--
-- CALL sp_register_user('new_user_proc', 'new_user_proc@example.com', 'hash_test');
-- SELECT user_id, username, email FROM users WHERE username = 'new_user_proc';
-- EXPECTED after fix: 1 new user row.

-- =============================================================================
-- 7) Ad-hoc joins (not procedures) — support groups sample
-- =============================================================================

-- Get user groups (replace ? with a user_id, e.g. 1)
SELECT sg.group_id, sg.group_name, gm.role
FROM group_memberships gm
JOIN support_groups sg ON gm.group_id = sg.group_id
WHERE gm.user_id = 1;

-- EXPECTED (after seed): user 1 appears in group(s) per seed (e.g. Gym Friends as owner, Morning Accountability as member).

-- Get group members (replace ? with group_id, e.g. 1)
SELECT u.user_id, u.username, gm.role
FROM group_memberships gm
JOIN users u ON gm.user_id = u.user_id
WHERE gm.group_id = 1;

-- EXPECTED (after seed): multiple members for group 1 per seed data.

-- =============================================================================
-- 8) tr_users_before_insert_dob / tr_users_before_update_dob (schema.sql + procedures.sql)
-- =============================================================================
-- Rejects date_of_birth strictly after CURDATE(). Both BEFORE INSERT and BEFORE UPDATE must exist,
-- or INSERTs with a future DOB will still succeed.

-- EXPECTED: error on UPDATE — future DOB not allowed (tests UPDATE trigger).
-- UPDATE users SET date_of_birth = DATE_ADD(CURDATE(), INTERVAL 1 DAY) WHERE username = 'past_ok';
Insert into users (username, email, password_hash, first_name, last_name, date_of_birth, gender, height_inches)
VALUES ('future_dob3', 'future3@example.com', 'x', 'A', 'B', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'other', 70);
-- EXPECTED: error SQLSTATE 45000 — future DOB not allowed.

Insert into users (username, email, password_hash, first_name, last_name, date_of_birth, gender, height_inches)
VALUES ('past_ok', 'past_ok@example.com', 'x', 'A', 'B', '2000-01-01', 'other', 70);
-- EXPECTED: succeeds — past or today is allowed (use a unique username/email).

SELECT * FROM users;
SELECT * FROM nutrition_logs;

