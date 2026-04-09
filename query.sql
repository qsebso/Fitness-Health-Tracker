USE fitness_db;

/*
create user 'quinn' and show CRUD for:
    Daily check-ins
    Daily metrics
    Workouts
    Nutrition logs

ACHIEVEMENT (auto when rules pass): add daily_metrics with steps >= 10000 on
5 CONSECUTIVE calendar days (same user). That unlocks "10K Steps Streak"
(code steps_streak_5). Rules run when you load the Dashboard (home "/") —
so after the 5th day, open Dashboard once, then check Achievements or run AFTER.
*/

SELECT * FROM users ORDER BY user_id;
SELECT * FROM daily_metrics ORDER BY metric_id;
SELECT * FROM nutrition_logs ORDER BY nutrition_id;
SELECT * FROM goals ORDER BY goal_id;
SELECT * FROM daily_checkins ORDER BY checkin_id;
SELECT * FROM achievement_definitions ORDER BY achievement_def_id;
SELECT * FROM user_achievements ORDER BY user_achievement_id;
SELECT * FROM exercise_types ORDER BY exercise_id;
SELECT * FROM workout_logs ORDER BY workout_id;

-- How workouts are related to exercises
SELECT
    u.username,
    wl.workout_id,
    wl.log_date,
    wl.duration_minutes,
    wl.calories_burned,
    et.name AS exercise_name,
    et.category,
    et.muscle_group
FROM workout_logs wl
JOIN users u ON u.user_id = wl.user_id
JOIN exercise_types et ON et.exercise_id = wl.exercise_id
ORDER BY wl.log_date DESC;

-- How achievements are related to users
SELECT
    u.username,
    ua.user_achievement_id,
    ad.code,
    ad.title,
    ua.achieved_at
FROM user_achievements ua
JOIN users u ON u.user_id = ua.user_id
JOIN achievement_definitions ad ON ad.achievement_def_id = ua.achievement_def_id
ORDER BY ua.achieved_at DESC, u.username;

/*
FINISH — log in as testuser. Demo: dashboard, then groups (create/delete,
post). For add/remove members use group name "test group" and member "quinn"
(see focused queries). Re-run after each UI action for before/after.
*/

SELECT * FROM users WHERE username = 'testuser';

SELECT * FROM progress_snapshots
WHERE user_id = (SELECT user_id FROM users WHERE username = 'testuser' LIMIT 1)
ORDER BY snapshot_date DESC;

-- Groups — raw tables (whole DB). Use these to prove create/delete group,
-- membership rows, and posts.
SELECT * FROM support_groups ORDER BY group_id;
SELECT * FROM group_memberships ORDER BY membership_id;
SELECT * FROM group_posts ORDER BY post_id;

/*
Add/remove member demo (fixed names: testuser and quinn):
As testuser, create a group named exactly:  test group
Before add: run the three queries below — quinn block should be empty (0 rows).
In app: add member quinn to that group — run again — quinn appears.
In app: remove quinn — run again — quinn row gone.
*/

SELECT * FROM support_groups WHERE group_name = 'test group';

SELECT
    gm.membership_id,
    sg.group_name,
    u.username,
    gm.role,
    gm.joined_at
FROM group_memberships gm
JOIN support_groups sg ON sg.group_id = gm.group_id
JOIN users u ON u.user_id = gm.user_id
WHERE sg.group_name = 'test group'
ORDER BY gm.role DESC, u.username;

-- Groups — same rows testuser sees on /groups (always has a membership row,
-- including owner when they create a group).
SELECT
    sg.group_id,
    sg.group_name,
    sg.description,
    creator.username AS created_by_username,
    gm.role AS testuser_role,
    sg.created_at
FROM support_groups sg
JOIN group_memberships gm ON gm.group_id = sg.group_id
JOIN users tu ON tu.user_id = gm.user_id AND tu.username = 'testuser'
JOIN users creator ON creator.user_id = sg.created_by_user_id
ORDER BY sg.group_id;

-- Members for those same groups (add / remove shows up here).
SELECT
    sg.group_id,
    sg.group_name,
    u.username,
    gm.role,
    gm.joined_at
FROM group_memberships gm
JOIN support_groups sg ON sg.group_id = gm.group_id
JOIN users u ON u.user_id = gm.user_id
WHERE sg.group_id IN (
    SELECT gm2.group_id
    FROM group_memberships gm2
    JOIN users tu ON tu.user_id = gm2.user_id AND tu.username = 'testuser'
)
ORDER BY sg.group_id, gm.role DESC, u.username;

-- Posts in testuser’s groups only (posting demo).
SELECT
    gp.post_id,
    sg.group_id,
    sg.group_name,
    u.username,
    gp.content,
    gp.created_at
FROM group_posts gp
JOIN support_groups sg ON sg.group_id = gp.group_id
JOIN users u ON u.user_id = gp.user_id
WHERE sg.group_id IN (
    SELECT gm.group_id
    FROM group_memberships gm
    JOIN users tu ON tu.user_id = gm.user_id AND tu.username = 'testuser'
)
ORDER BY gp.created_at DESC;
