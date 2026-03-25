-- Used for: Seed data and initial lookup values.
-- Information inside: Seed/bootstrapping inserts for common baseline records.

INSERT INTO support_groups (group_name, group_type, created_by_user_id)
VALUES ('Gym Friends', 'friends', 1);

INSERT INTO group_memberships (group_id, user_id, role)
VALUES (1, 1, 'owner'), (1, 2, 'member');

