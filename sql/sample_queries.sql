-- Example calls against procedures.sql. Run schema.sql, seed.sql, then procedures.sql first.

USE fitness_db;

-- sp_upsert_daily_checkin: insert (user 1 has no row for this date in seed)
CALL sp_upsert_daily_checkin(
    1,
    '2026-03-17',
    'good',
    'high',
    'good',
    'First insert for this date.'
);

SELECT checkin_id, user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes
FROM daily_checkins
WHERE user_id = 1 AND record_date = '2026-03-17';

-- Same (user_id, record_date): should update, not duplicate
CALL sp_upsert_daily_checkin(
    1,
    '2026-03-17',
    'average',
    'medium',
    'average',
    'Upsert updated this row.'
);

SELECT checkin_id, user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes
FROM daily_checkins
WHERE user_id = 1 AND record_date = '2026-03-17';

-- Upsert on an existing seed date
CALL sp_upsert_daily_checkin(
    1,
    '2026-03-14',
    'good',
    'high',
    'good',
    'Updated from sample query run.'
);

SELECT eating_quality, energy_level, adherence_to_plan, notes
FROM daily_checkins
WHERE user_id = 1 AND record_date = '2026-03-14';

-- sp_upsert_daily_metric
CALL sp_upsert_daily_metric(1, '2026-03-17', 181.50, 11000, 7.25, 9.50);

SELECT metric_id, user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups
FROM daily_metrics
WHERE user_id = 1 AND record_date = '2026-03-17';

CALL sp_upsert_daily_metric(1, '2026-03-17', 181.00, 11500, 8.00, 10.00);

SELECT weight_lbs, steps, sleep_hours, water_intake_cups
FROM daily_metrics
WHERE user_id = 1 AND record_date = '2026-03-17';

-- sp_log_nutrition_entry
CALL sp_log_nutrition_entry(
    1,
    '2026-03-17 12:30:00',
    'lunch',
    'Sample procedure meal',
    550,
    35.00,
    55.00,
    18.00
);

SELECT nutrition_id, user_id, meal_type, food_item, calories, protein_g, carbs_g, fat_g, log_date
FROM nutrition_logs
WHERE user_id = 1 AND food_item = 'Sample procedure meal'
ORDER BY nutrition_id DESC
LIMIT 1;

-- sp_register_user (all columns required by schema)
CALL sp_register_user(
    'sample_reg_user',
    'sample_reg_user@example.com',
    'SampleReg1',
    'Sample',
    'User',
    '2000-01-15',
    'other',
    70
);

SELECT user_id, username, email FROM users WHERE username = 'sample_reg_user';

-- Groups: memberships for user 1 (matches seed)
SELECT sg.group_id, sg.group_name, gm.role
FROM group_memberships gm
JOIN support_groups sg ON gm.group_id = sg.group_id
WHERE gm.user_id = 1;

-- Group 1 members
SELECT u.user_id, u.username, gm.role
FROM group_memberships gm
JOIN users u ON gm.user_id = u.user_id
WHERE gm.group_id = 1;

-- tr_users_before_insert_dob: next line should error (SQLSTATE 45000); skip or comment it out to run the rest in one batch.
INSERT INTO users (username, email, password, first_name, last_name, date_of_birth, gender, height_inches)
VALUES ('future_dob_test', 'future_dob_test@example.com', 'x', 'A', 'B', DATE_ADD(CURDATE(), INTERVAL 1 DAY), 'other', 70);

-- Valid DOB (use a unique username if re-running)
INSERT INTO users (username, email, password, first_name, last_name, date_of_birth, gender, height_inches)
VALUES ('past_ok', 'past_ok@example.com', 'x', 'A', 'B', '2000-01-01', 'other', 70);

SELECT * FROM users;
SELECT * FROM nutrition_logs;

-- fn_est_calories_burned (stored function): estimated kcal for duration at given calories-per-hour rate
SELECT fn_est_calories_burned(700.00, 45) AS est_calories_45min_at_700_per_hr;
