-- Used for: Example CRUD / reporting SQL queries for documentation and testing.
-- Information inside: Representative queries that match the current schema.

-- Get user groups
SELECT sg.group_id, sg.group_name, gm.role
FROM group_memberships gm
JOIN support_groups sg ON gm.group_id = sg.group_id
WHERE gm.user_id = ?;

-- Get group members
SELECT u.user_id, u.username, gm.role
FROM group_memberships gm
JOIN users u ON gm.user_id = u.user_id
WHERE gm.group_id = ?;

