-- Used for: Seed data and initial lookup values.
-- Information inside: Varied sample records across all tables for functional testing.
use fitness_db;
-- NOTE:
-- - Assumes schema.sql has already been run.
-- - Insert order follows FK dependencies.
-- - Password values are plain text for demo/grading (matches app behavior).

INSERT INTO users (username, email, password, first_name, last_name, date_of_birth, gender, height_inches)
VALUES
    ('alex_fit', 'alex.fit@example.com', 'hash_alex', 'Alex', 'Turner', '1998-04-12', 'male', 71),
    ('mia_runner', 'mia.runner@example.com', 'hash_mia', 'Mia', 'Lopez', '2001-09-03', 'female', 65),
    ('sam_strength', 'sam.strength@example.com', 'hash_sam', 'Sam', 'Patel', '1995-01-28', 'other', 70),
    ('jordan_cycle', 'jordan.cycle@example.com', 'hash_jordan', 'Jordan', 'Kim', '1992-06-17', 'male', 68),
    ('ava_balance', 'ava.balance@example.com', 'hash_ava', 'Ava', 'Nguyen', '1999-11-22', 'female', 64),
    -- Development seed account requested for UI testing.
    ('quinn', 'quinn@example.com', 'quinn', 'Quinn', 'Tester', '1999-05-15', 'other', 69);

INSERT INTO exercise_types (name, category, muscle_group, calories_per_hour)
VALUES
    ('Push-ups', 'Strength', 'Chest', 420.00),
    ('Pull-ups', 'Strength', 'Back', 500.00),
    ('Squats', 'Strength', 'Legs', 450.00),
    ('Running', 'Cardio', 'Full Body', 700.00),
    ('Cycling', 'Cardio', 'Legs', 600.00),
    ('Yoga', 'Mobility', 'Core', 260.00),
    ('Plank', 'Strength', 'Core', 300.00);

INSERT INTO daily_metrics (user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups)
VALUES
    (1, '2026-03-14', 182.4, 9200, 7.5, 10.0),
    (1, '2026-03-15', 182.0, 10400, 8.0, 11.5),
    (2, '2026-03-14', 140.2, 13200, 7.0, 9.0),
    (2, '2026-03-15', 139.8, 11850, 6.5, 8.5),
    (3, '2026-03-14', 168.7, 7600, 8.5, 12.0),
    (4, '2026-03-14', 175.1, 15000, 6.0, 7.5),
    (5, '2026-03-14', 128.5, 8900, 7.8, 10.0);

INSERT INTO nutrition_logs (user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g)
VALUES
    (1, '2026-03-14 08:15:00', 'breakfast', 'Greek yogurt with berries', 320, 24.0, 35.0, 8.0),
    (1, '2026-03-14 13:05:00', 'lunch', 'Chicken rice bowl', 640, 42.0, 68.0, 18.0),
    (1, '2026-03-14 19:10:00', 'dinner', 'Salmon and vegetables', 710, 46.0, 40.0, 32.0),
    (2, '2026-03-14 12:20:00', 'lunch', 'Turkey wrap', 520, 31.0, 49.0, 17.0),
    (2, '2026-03-14 16:10:00', 'snack', 'Protein shake', 210, 30.0, 9.0, 4.0),
    (3, '2026-03-14 07:50:00', 'breakfast', 'Oatmeal with banana', 410, 14.0, 72.0, 7.0),
    (4, '2026-03-14 20:00:00', 'dinner', 'Steak and sweet potato', 780, 52.0, 48.0, 35.0),
    (5, '2026-03-14 18:40:00', 'dinner', 'Tofu stir-fry', 560, 28.0, 62.0, 20.0);

INSERT INTO goals (user_id, goal_type, target_value, start_date, end_date, status)
VALUES
    (1, 'weight_loss', 175.0, '2026-03-01', '2026-06-01', 'active'),
    (2, 'endurance', 10.0, '2026-02-15', '2026-05-15', 'active'),
    (3, 'muscle_gain', 8.0, '2026-01-10', NULL, 'paused'),
    (4, 'weight_gain', 182.0, '2025-12-01', '2026-03-01', 'completed'),
    (5, 'endurance', 5.0, '2026-03-10', '2026-04-30', 'active');

INSERT INTO daily_checkins (user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes)
VALUES
    (1, '2026-03-14', 'good', 'high', 'good', 'Great workout consistency this week.'),
    (2, '2026-03-14', 'average', 'medium', 'good', 'Missed one snack but stayed on plan.'),
    (3, '2026-03-14', 'good', 'low', 'average', 'Low energy day, focused on mobility.'),
    (4, '2026-03-14', 'poor', 'medium', 'poor', 'Work stress affected meals and workout.'),
    (5, '2026-03-14', 'good', 'high', 'good', 'Hydration and sleep improved.');

INSERT INTO workout_logs (user_id, exercise_id, log_date, duration_minutes, calories_burned, notes)
VALUES
    (1, 4, '2026-03-14 06:30:00', 45, 525.0, 'Steady pace run'),
    (1, 1, '2026-03-15 18:00:00', 20, 140.0, 'Bodyweight circuit'),
    (2, 5, '2026-03-14 07:00:00', 60, 600.0, 'Outdoor cycling'),
    (3, 6, '2026-03-14 19:00:00', 50, 216.7, 'Recovery yoga session'),
    (4, 2, '2026-03-14 17:15:00', 25, 208.3, 'Pull-up progression'),
    (5, 3, '2026-03-14 16:45:00', 35, 262.5, 'Lower body focus');

INSERT INTO achievement_definitions (code, title, description)
VALUES
    ('steps_streak_5', '10K Steps Streak', 'Hit at least 10,000 steps for 5 consecutive days.'),
    ('meal_prep_14', 'Meal Prep Master', 'Logged all meals for 14 straight days.'),
    ('yoga_20', 'Mobility Milestone', 'Completed 20 yoga sessions.'),
    ('hydration_god', 'Hydration Hero', 'Met daily water goal for 2 weeks.');

INSERT INTO user_achievements (user_id, achievement_def_id, achieved_at)
VALUES
    (1, 1, '2026-03-15 09:00:00'),
    (2, 2, '2026-03-14 21:00:00'),
    (3, 3, '2026-03-13 20:30:00'),
    (3, 4, '2026-03-13 20:30:00'),
    (5, 4, '2026-03-14 22:15:00');

INSERT INTO progress_snapshots (user_id, snapshot_date, avg_weight_lbs_7d, total_workouts_7d, avg_steps_7d, avg_sleep_hours_7d, avg_protein_g_7d)
VALUES
    (1, '2026-03-15', 182.2, 4, 9900.0, 7.7, 132.5),
    (2, '2026-03-15', 140.0, 5, 12420.0, 6.8, 118.0),
    (3, '2026-03-15', 168.7, 3, 8100.0, 8.1, 102.4),
    (4, '2026-03-15', 175.1, 2, 14100.0, 6.4, 125.7),
    (5, '2026-03-15', 128.5, 3, 9300.0, 7.9, 97.3);

INSERT INTO support_groups (group_name, description, created_by_user_id)
VALUES
    ('Progress Crew', 'poster board group with sample posts', 6),
    ('Family Wellness', 'group without posts for empty-state testing', 2),
    ('Morning Accountability', 'accountability', 3);

INSERT INTO group_memberships (group_id, user_id, role)
VALUES
    (1, 6, 'owner'),
    (1, 1, 'member'),
    (1, 2, 'member'),
    (1, 3, 'member'),
    (2, 2, 'owner'),
    (2, 6, 'member'),
    (2, 5, 'member'),
    (3, 3, 'owner'),
    (3, 1, 'member'),
    (3, 4, 'member');

INSERT INTO group_posts (group_id, user_id, content, created_at)
VALUES
    (1, 6, 'Just lost 5 lbs this month. Small steps, big wins!', '2026-03-15 08:10:00'),
    (1, 1, 'Huge congrats Quinn! Keep it going.', '2026-03-15 08:20:00'),
    (1, 2, 'Nice work! I finally hit 12k steps today too.', '2026-03-15 09:05:00');

-- Quinn (user_id 6): dashboard demo — active goal, metrics streaks, nutrition streak, 20+ yoga, snapshots, earned badges
INSERT INTO goals (user_id, goal_type, target_value, start_date, end_date, status)
VALUES (6, 'weight_loss', 165.0, '2026-03-01', '2026-06-30', 'active');

INSERT INTO daily_checkins (user_id, record_date, eating_quality, energy_level, adherence_to_plan, notes)
VALUES
    (6, '2026-03-27', 'good', 'high', 'good', 'Solid week.'),
    (6, '2026-03-28', 'average', 'medium', 'good', NULL),
    (6, '2026-03-29', 'good', 'high', 'good', 'Hit step goal again.');

INSERT INTO daily_metrics (user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups)
VALUES
    (6, '2026-03-16', 172.4, 9300, 7.5, 10.0),
    (6, '2026-03-17', 172.2, 9100, 7.25, 9.5),
    (6, '2026-03-18', 172.0, 9400, 7.0, 10.0),
    (6, '2026-03-19', 171.9, 9200, 7.5, 9.0),
    (6, '2026-03-20', 171.8, 9500, 6.75, 10.0),
    (6, '2026-03-21', 171.7, 8800, 8.0, 10.0),
    (6, '2026-03-22', 171.6, 9100, 7.5, 9.5),
    (6, '2026-03-23', 171.5, 9000, 7.25, 10.0),
    (6, '2026-03-24', 171.4, 8900, 7.5, 9.0),
    (6, '2026-03-25', 171.3, 10400, 7.5, 10.0),
    (6, '2026-03-26', 171.2, 10600, 7.0, 10.0),
    (6, '2026-03-27', 171.1, 10800, 7.5, 10.0),
    (6, '2026-03-28', 171.0, 11000, 7.25, 10.0),
    (6, '2026-03-29', 170.9, 11200, 7.5, 10.0);

INSERT INTO nutrition_logs (user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g)
VALUES
    (6, '2026-03-16 12:00:00', 'lunch', 'Chicken bowl', 580, 42.0, 55.0, 18.0),
    (6, '2026-03-17 12:00:00', 'lunch', 'Salmon salad', 520, 38.0, 28.0, 24.0),
    (6, '2026-03-18 12:00:00', 'lunch', 'Turkey wrap', 510, 32.0, 48.0, 16.0),
    (6, '2026-03-19 12:00:00', 'lunch', 'Tofu bowl', 540, 30.0, 62.0, 18.0),
    (6, '2026-03-20 12:00:00', 'lunch', 'Greek yogurt plate', 480, 28.0, 40.0, 14.0),
    (6, '2026-03-21 12:00:00', 'lunch', 'Steak salad', 620, 45.0, 22.0, 35.0),
    (6, '2026-03-22 12:00:00', 'lunch', 'Lentil soup + bread', 560, 24.0, 78.0, 12.0),
    (6, '2026-03-23 12:00:00', 'lunch', 'Sushi combo', 590, 32.0, 70.0, 14.0),
    (6, '2026-03-24 12:00:00', 'lunch', 'Chicken Caesar', 550, 40.0, 30.0, 28.0),
    (6, '2026-03-25 12:00:00', 'lunch', 'Buddha bowl', 530, 22.0, 68.0, 16.0),
    (6, '2026-03-26 12:00:00', 'lunch', 'Tuna melt', 540, 35.0, 42.0, 22.0),
    (6, '2026-03-27 12:00:00', 'lunch', 'Burrito bowl', 640, 36.0, 72.0, 20.0),
    (6, '2026-03-28 12:00:00', 'lunch', 'Pho', 480, 28.0, 58.0, 12.0),
    (6, '2026-03-29 12:00:00', 'lunch', 'Mediterranean plate', 560, 34.0, 45.0, 22.0);

INSERT INTO workout_logs (user_id, exercise_id, log_date, duration_minutes, calories_burned, notes)
VALUES
    (6, 6, '2026-03-05 07:00:00', 40, 173.3, 'Yoga flow'),
    (6, 6, '2026-03-06 07:10:00', 40, 173.3, 'Yoga flow'),
    (6, 6, '2026-03-07 18:00:00', 45, 195.0, 'Yin yoga'),
    (6, 6, '2026-03-08 07:05:00', 35, 151.7, 'Sun salutations'),
    (6, 6, '2026-03-09 07:15:00', 40, 173.3, 'Yoga flow'),
    (6, 6, '2026-03-10 17:30:00', 50, 216.7, 'Power yoga'),
    (6, 6, '2026-03-11 07:00:00', 40, 173.3, 'Morning yoga'),
    (6, 6, '2026-03-12 07:20:00', 45, 195.0, 'Vinyasa'),
    (6, 6, '2026-03-13 08:00:00', 30, 130.0, 'Stretch'),
    (6, 6, '2026-03-14 09:00:00', 40, 173.3, 'Yoga flow'),
    (6, 6, '2026-03-15 07:30:00', 45, 195.0, 'Yoga'),
    (6, 6, '2026-03-16 18:15:00', 40, 173.3, 'Evening yoga'),
    (6, 6, '2026-03-17 07:00:00', 35, 151.7, 'Yoga'),
    (6, 6, '2026-03-18 19:00:00', 50, 216.7, 'Hot yoga'),
    (6, 6, '2026-03-19 07:10:00', 40, 173.3, 'Yoga flow'),
    (6, 6, '2026-03-20 07:00:00', 45, 195.0, 'Yoga'),
    (6, 6, '2026-03-21 10:00:00', 40, 173.3, 'Weekend yoga'),
    (6, 6, '2026-03-22 07:15:00', 40, 173.3, 'Yoga flow'),
    (6, 6, '2026-03-23 17:45:00', 35, 151.7, 'Yoga'),
    (6, 6, '2026-03-24 07:00:00', 45, 195.0, 'Yoga'),
    (6, 6, '2026-03-25 18:00:00', 40, 173.3, 'Recovery yoga'),
    (6, 6, '2026-03-26 07:30:00', 40, 173.3, 'Yoga flow'),
    (6, 6, '2026-03-27 07:00:00', 45, 195.0, 'Yoga'),
    (6, 6, '2026-03-28 08:30:00', 40, 173.3, 'Yoga'),
    (6, 6, '2026-03-29 07:00:00', 45, 195.0, 'Yoga');

INSERT INTO progress_snapshots (user_id, snapshot_date, avg_weight_lbs_7d, total_workouts_7d, avg_steps_7d, avg_sleep_hours_7d, avg_protein_g_7d)
VALUES
    (6, '2026-03-27', 171.35, 18, 10120.0, 7.45, 36.5),
    (6, '2026-03-29', 171.05, 22, 10380.0, 7.42, 38.2);

INSERT INTO user_achievements (user_id, achievement_def_id, achieved_at)
VALUES
    (6, 1, '2026-03-29 08:00:00'),
    (6, 2, '2026-03-29 08:01:00'),
    (6, 3, '2026-03-29 08:02:00'),
    (6, 4, '2026-03-29 08:03:00');

