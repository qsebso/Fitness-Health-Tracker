-- Used for: Database schema definition (tables, PK/FK/UNIQUE/CHECK constraints).
-- Information inside: Finalized DDL for the fitness tracker schema, including support groups.
DROP SCHEMA IF EXISTS fitness_db;
CREATE SCHEMA fitness_db;
use fitness_db;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('male', 'female', 'other') NOT NULL,
    height_inches INT NOT NULL CHECK (height_inches > 0 AND height_inches < 120),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE daily_metrics (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    record_date DATE NOT NULL,
    weight_lbs DECIMAL(5,2) NOT NULL CHECK (weight_lbs > 0 AND weight_lbs < 1000),
    steps INT NOT NULL CHECK (steps >= 0 AND steps < 100000),
    sleep_hours DECIMAL(5,2) NOT NULL CHECK (sleep_hours >= 0 AND sleep_hours <= 24),
    water_intake_cups DECIMAL(5,2) NOT NULL CHECK (water_intake_cups >= 0 AND water_intake_cups < 100),
    CONSTRAINT unique_metric_per_day UNIQUE (user_id, record_date),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE nutrition_logs (
    nutrition_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    log_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    meal_type ENUM('breakfast', 'lunch', 'dinner', 'snack') NOT NULL,
    food_item VARCHAR(255) NOT NULL,
    calories INT CHECK (calories >= 0 AND calories < 10000),
    protein_g DECIMAL(6,2) NOT NULL CHECK (protein_g >= 0 AND protein_g < 1000),
    carbs_g DECIMAL(6,2) CHECK (carbs_g >= 0 AND carbs_g < 1000),
    fat_g DECIMAL(6,2) CHECK (fat_g >= 0 AND fat_g < 1000),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE goals (
    goal_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    goal_type ENUM('weight_loss', 'weight_gain', 'muscle_gain', 'endurance') NOT NULL,
    target_value DECIMAL(6,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('active', 'completed', 'paused') NOT NULL,
    CHECK (end_date IS NULL OR end_date > start_date),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE daily_checkins (
    checkin_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    record_date DATE NOT NULL,
    eating_quality ENUM('poor', 'average', 'good') NOT NULL,
    energy_level ENUM('low', 'medium', 'high') NOT NULL,
    adherence_to_plan ENUM('poor', 'average', 'good') NOT NULL,
    notes TEXT,
    CONSTRAINT unique_checkin_per_day UNIQUE (user_id, record_date),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE achievements (
    achievement_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    achieved_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE exercise_types (
    exercise_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    category VARCHAR(255) NOT NULL,
    muscle_group VARCHAR(255) NOT NULL,
    calories_per_hour DECIMAL(5,2) CHECK (calories_per_hour > 0)
);

CREATE TABLE workout_logs (
    workout_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exercise_id INT NOT NULL,
    log_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    calories_burned DECIMAL(6,2) CHECK (calories_burned >= 0),
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (exercise_id) REFERENCES exercise_types(exercise_id) ON DELETE RESTRICT
);

CREATE TABLE progress_snapshots (
    snapshot_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    snapshot_date DATE NOT NULL,
    avg_weight_lbs_7d DECIMAL(5,2) NOT NULL,
    total_workouts_7d INT NOT NULL,
    avg_steps_7d DECIMAL(8,2),
    avg_sleep_hours_7d DECIMAL(4,2),
    avg_protein_g_7d DECIMAL(6,2), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_snapshot_per_day UNIQUE (user_id, snapshot_date)
);

CREATE TABLE support_groups (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    created_by_user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE group_memberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('owner', 'member') NOT NULL DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_group_membership UNIQUE (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES support_groups(group_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
