-- Stored procedures, triggers, and functions for fitness_db. Run after schema.sql.

USE fitness_db;

DROP PROCEDURE IF EXISTS sp_register_user;
DROP PROCEDURE IF EXISTS sp_get_user_auth_by_username;
DROP PROCEDURE IF EXISTS sp_get_user_by_id;
DROP PROCEDURE IF EXISTS sp_update_user_profile;
DROP PROCEDURE IF EXISTS sp_update_user_password;
DROP PROCEDURE IF EXISTS sp_upsert_exercise_type;
DROP PROCEDURE IF EXISTS sp_list_exercise_types;
DROP PROCEDURE IF EXISTS sp_upsert_daily_metric;
DROP PROCEDURE IF EXISTS sp_get_user_daily_metrics;
DROP PROCEDURE IF EXISTS sp_delete_daily_metric;
DROP PROCEDURE IF EXISTS sp_upsert_daily_checkin;
DROP PROCEDURE IF EXISTS sp_get_user_daily_checkins;
DROP PROCEDURE IF EXISTS sp_log_nutrition_entry;
DROP PROCEDURE IF EXISTS sp_update_nutrition_entry;
DROP PROCEDURE IF EXISTS sp_delete_nutrition_entry;
DROP PROCEDURE IF EXISTS sp_get_user_nutrition_logs;
DROP PROCEDURE IF EXISTS sp_log_workout;
DROP PROCEDURE IF EXISTS sp_update_workout_log;
DROP PROCEDURE IF EXISTS sp_delete_workout_log;
DROP PROCEDURE IF EXISTS sp_get_user_workout_logs;
DROP PROCEDURE IF EXISTS sp_create_goal;
DROP PROCEDURE IF EXISTS sp_update_goal_status;
DROP PROCEDURE IF EXISTS sp_update_goal;
DROP PROCEDURE IF EXISTS sp_get_user_goals;
DROP PROCEDURE IF EXISTS sp_delete_goal;
DROP PROCEDURE IF EXISTS sp_get_user_progress_snapshots;
DROP PROCEDURE IF EXISTS sp_grant_user_achievement;
DROP PROCEDURE IF EXISTS sp_grant_user_achievement_by_code;
DROP PROCEDURE IF EXISTS sp_list_achievement_definitions;
DROP PROCEDURE IF EXISTS sp_get_user_achievements;
DROP PROCEDURE IF EXISTS sp_create_support_group;
DROP PROCEDURE IF EXISTS sp_add_group_member;
DROP PROCEDURE IF EXISTS sp_remove_group_member;
DROP PROCEDURE IF EXISTS sp_get_group_members;
DROP PROCEDURE IF EXISTS sp_get_user_groups;
DROP PROCEDURE IF EXISTS sp_create_group_post;
DROP PROCEDURE IF EXISTS sp_get_group_posts;

DROP TRIGGER IF EXISTS tr_users_before_insert_dob;
DROP TRIGGER IF EXISTS tr_users_before_update_dob;
DROP FUNCTION IF EXISTS fn_est_calories_burned;

-- users
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

CREATE PROCEDURE sp_register_user(
    IN p_username VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_password VARCHAR(255),
    IN p_first_name VARCHAR(255),
    IN p_last_name VARCHAR(255),
    IN p_date_of_birth DATE,
    IN p_gender ENUM('male', 'female', 'other'),
    IN p_height_inches INT
)
BEGIN
    INSERT INTO users (
        username, email, password, first_name, last_name, date_of_birth, gender, height_inches
    )
    VALUES (
        p_username, p_email, p_password, p_first_name, p_last_name, p_date_of_birth, p_gender, p_height_inches
    );
    SELECT LAST_INSERT_ID() AS user_id;
END$$

CREATE PROCEDURE sp_get_user_auth_by_username(IN p_username VARCHAR(255))
BEGIN
    SELECT user_id, username, email, password
    FROM users
    WHERE username = p_username;
END$$

CREATE PROCEDURE sp_get_user_by_id(IN p_user_id INT)
BEGIN
    SELECT user_id, username, email, first_name, last_name, gender, height_inches, date_of_birth
    FROM users
    WHERE user_id = p_user_id;
END$$

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

CREATE PROCEDURE sp_update_user_password(
    IN p_user_id INT,
    IN p_password VARCHAR(255)
)
BEGIN
    UPDATE users
    SET password = p_password
    WHERE user_id = p_user_id;
END$$

DELIMITER ;

-- exercise_types
DELIMITER $$

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

CREATE PROCEDURE sp_list_exercise_types()
BEGIN
    SELECT exercise_id, name, category, muscle_group, calories_per_hour
    FROM exercise_types
    ORDER BY name;
END$$

DELIMITER ;

-- daily_metrics
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
END$$

CREATE PROCEDURE sp_get_user_daily_metrics(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        metric_id,
        user_id,
        record_date,
        weight_lbs,
        steps,
        sleep_hours,
        water_intake_cups
    FROM daily_metrics
    WHERE user_id = p_user_id
    ORDER BY record_date DESC
    LIMIT p_limit;
END$$

CREATE PROCEDURE sp_delete_daily_metric(IN p_metric_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM daily_metrics
    WHERE metric_id = p_metric_id
      AND user_id = p_user_id;
END$$

DELIMITER ;

-- daily_checkins
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
END$$

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

-- nutrition_logs
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
END$$

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

CREATE PROCEDURE sp_delete_nutrition_entry(IN p_nutrition_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM nutrition_logs
    WHERE nutrition_id = p_nutrition_id
      AND user_id = p_user_id;
END$$

CREATE PROCEDURE sp_get_user_nutrition_logs(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        nutrition_id,
        user_id,
        log_date,
        meal_type,
        food_item,
        calories,
        protein_g,
        carbs_g,
        fat_g
    FROM nutrition_logs
    WHERE user_id = p_user_id
    ORDER BY log_date DESC, nutrition_id DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- workout_logs (uses fn_est_calories_burned when p_calories_burned IS NULL)
DELIMITER $$

CREATE FUNCTION fn_est_calories_burned(
    p_calories_per_hour DECIMAL(5,2),
    p_duration_minutes INT
) RETURNS DECIMAL(10,2)
    DETERMINISTIC
    NO SQL
BEGIN
    IF p_duration_minutes IS NULL OR p_duration_minutes < 1 THEN
        RETURN NULL;
    END IF;
    IF p_calories_per_hour IS NULL OR p_calories_per_hour <= 0 THEN
        RETURN NULL;
    END IF;
    RETURN ROUND((p_calories_per_hour / 60.0) * p_duration_minutes, 2);
END$$

CREATE PROCEDURE sp_log_workout(
    IN p_user_id INT,
    IN p_exercise_id INT,
    IN p_log_date TIMESTAMP,
    IN p_duration_minutes INT,
    IN p_calories_burned DECIMAL(6,2),
    IN p_notes TEXT
)
BEGIN
    DECLARE v_cal DECIMAL(6,2);
    DECLARE v_cph DECIMAL(5,2);

    IF p_calories_burned IS NOT NULL THEN
        SET v_cal = p_calories_burned;
    ELSE
        SELECT calories_per_hour INTO v_cph
        FROM exercise_types
        WHERE exercise_id = p_exercise_id
        LIMIT 1;
        SET v_cal = fn_est_calories_burned(v_cph, p_duration_minutes);
    END IF;

    INSERT INTO workout_logs (user_id, exercise_id, log_date, duration_minutes, calories_burned, notes)
    VALUES (p_user_id, p_exercise_id, p_log_date, p_duration_minutes, v_cal, p_notes);
END$$

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
    DECLARE v_cal DECIMAL(6,2);
    DECLARE v_cph DECIMAL(5,2);

    IF p_calories_burned IS NOT NULL THEN
        SET v_cal = p_calories_burned;
    ELSE
        SELECT calories_per_hour INTO v_cph
        FROM exercise_types
        WHERE exercise_id = p_exercise_id
        LIMIT 1;
        SET v_cal = fn_est_calories_burned(v_cph, p_duration_minutes);
    END IF;

    UPDATE workout_logs
    SET
        exercise_id = p_exercise_id,
        log_date = p_log_date,
        duration_minutes = p_duration_minutes,
        calories_burned = v_cal,
        notes = p_notes
    WHERE workout_id = p_workout_id
      AND user_id = p_user_id;
END$$

CREATE PROCEDURE sp_delete_workout_log(IN p_workout_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM workout_logs
    WHERE workout_id = p_workout_id
      AND user_id = p_user_id;
END$$

CREATE PROCEDURE sp_get_user_workout_logs(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        w.workout_id,
        w.user_id,
        w.exercise_id,
        w.log_date,
        w.duration_minutes,
        w.calories_burned,
        w.notes,
        e.name AS exercise_name
    FROM workout_logs w
    JOIN exercise_types e ON e.exercise_id = w.exercise_id
    WHERE w.user_id = p_user_id
    ORDER BY w.log_date DESC, w.workout_id DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- goals
DELIMITER $$

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

CREATE PROCEDURE sp_get_user_goals(IN p_user_id INT)
BEGIN
    SELECT
        goal_id,
        user_id,
        goal_type,
        target_value,
        start_date,
        end_date,
        status
    FROM goals
    WHERE user_id = p_user_id
    ORDER BY start_date DESC, goal_id DESC;
END$$

CREATE PROCEDURE sp_delete_goal(IN p_goal_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM goals
    WHERE goal_id = p_goal_id
      AND user_id = p_user_id;
END$$

CREATE PROCEDURE sp_get_user_progress_snapshots(IN p_user_id INT, IN p_limit INT)
BEGIN
    SELECT
        snapshot_id,
        user_id,
        snapshot_date,
        avg_weight_lbs_7d,
        total_workouts_7d,
        avg_steps_7d,
        avg_sleep_hours_7d,
        avg_protein_g_7d,
        created_at
    FROM progress_snapshots
    WHERE user_id = p_user_id
    ORDER BY snapshot_date DESC
    LIMIT p_limit;
END$$

DELIMITER ;

-- achievements
DELIMITER $$

CREATE PROCEDURE sp_grant_user_achievement(
    IN p_user_id INT,
    IN p_achievement_def_id INT,
    IN p_achieved_at TIMESTAMP
)
BEGIN
    INSERT IGNORE INTO user_achievements (user_id, achievement_def_id, achieved_at)
    VALUES (p_user_id, p_achievement_def_id, p_achieved_at);
END$$

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

CREATE PROCEDURE sp_list_achievement_definitions()
BEGIN
    SELECT achievement_def_id, code, title, description
    FROM achievement_definitions
    ORDER BY achievement_def_id;
END$$

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

-- support_groups
DELIMITER $$

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

CREATE PROCEDURE sp_add_group_member(
    IN p_group_id INT,
    IN p_user_id INT,
    IN p_role ENUM('owner', 'member')
)
BEGIN
    INSERT INTO group_memberships (group_id, user_id, role)
    VALUES (p_group_id, p_user_id, p_role);
END$$

CREATE PROCEDURE sp_remove_group_member(IN p_group_id INT, IN p_user_id INT)
BEGIN
    DELETE FROM group_memberships
    WHERE group_id = p_group_id
      AND user_id = p_user_id;
END$$

CREATE PROCEDURE sp_get_group_members(IN p_group_id INT)
BEGIN
    SELECT u.user_id, u.username, gm.role
    FROM group_memberships gm
    JOIN users u ON gm.user_id = u.user_id
    WHERE gm.group_id = p_group_id;
END$$

CREATE PROCEDURE sp_get_user_groups(IN p_user_id INT)
BEGIN
    SELECT sg.group_id, sg.group_name, gm.role
    FROM group_memberships gm
    JOIN support_groups sg ON gm.group_id = sg.group_id
    WHERE gm.user_id = p_user_id;
END$$

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
