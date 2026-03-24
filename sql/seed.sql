-- Used for: Seed data and initial lookup values.
-- Information inside: Varied sample records across all tables for functional testing.
use fitness_db;
-- NOTE:
-- - Assumes schema.sql has already been run.
-- - Insert order follows FK dependencies.
-- - Password values below are placeholder hashes for development/testing only.

INSERT INTO users (username, email, password_hash, first_name, last_name, date_of_birth, gender, height_inches)
VALUES
    ('alex_fit', 'alex.fit@example.com', 'hash_alex', 'Alex', 'Turner', '1998-04-12', 'male', 71),
    ('mia_runner', 'mia.runner@example.com', 'hash_mia', 'Mia', 'Lopez', '2001-09-03', 'female', 65),
    ('sam_strength', 'sam.strength@example.com', 'hash_sam', 'Sam', 'Patel', '1995-01-28', 'other', 70),
    ('jordan_cycle', 'jordan.cycle@example.com', 'hash_jordan', 'Jordan', 'Kim', '1992-06-17', 'male', 68),
    ('ava_balance', 'ava.balance@example.com', 'hash_ava', 'Ava', 'Nguyen', '1999-11-22', 'female', 64);

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

INSERT INTO achievements (user_id, title, description, achieved_at)
VALUES
    (1, '10K Steps Streak', 'Hit at least 10,000 steps for 5 consecutive days.', '2026-03-15 09:00:00'),
    (2, 'Meal Prep Master', 'Logged all meals for 14 straight days.', '2026-03-14 21:00:00'),
    (3, 'Mobility Milestone', 'Completed 20 yoga sessions.', '2026-03-13 20:30:00'),
    (5, 'Hydration Hero', 'Met daily water goal for 2 weeks.', '2026-03-14 22:15:00');

INSERT INTO progress_snapshots (user_id, snapshot_date, avg_weight_lbs_7d, total_workouts_7d, avg_steps_7d, avg_sleep_hours_7d, avg_protein_g_7d)
VALUES
    (1, '2026-03-15', 182.2, 4, 9900.0, 7.7, 132.5),
    (2, '2026-03-15', 140.0, 5, 12420.0, 6.8, 118.0),
    (3, '2026-03-15', 168.7, 3, 8100.0, 8.1, 102.4),
    (4, '2026-03-15', 175.1, 2, 14100.0, 6.4, 125.7),
    (5, '2026-03-15', 128.5, 3, 9300.0, 7.9, 97.3);

INSERT INTO support_groups (group_name, description, created_by_user_id)
VALUES
    ('Gym Friends', 'friends', 1),
    ('Family Wellness', 'family', 2),
    ('Morning Accountability', 'accountability', 3);

INSERT INTO group_memberships (group_id, user_id, role)
VALUES
    (1, 1, 'owner'),
    (1, 2, 'member'),
    (1, 3, 'member'),
    (2, 2, 'owner'),
    (2, 5, 'member'),
    (3, 3, 'owner'),
    (3, 1, 'member'),
    (3, 4, 'member');

