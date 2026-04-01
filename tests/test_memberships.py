"""Group membership actions (GroupService mocked)."""

from unittest.mock import patch


def test_add_member_as_owner_redirects(auth_client):
    group_row = {"group_id": 3, "group_name": "G", "role": "owner"}
    with (
        patch("app.routers.groups.GroupService.list_user_groups", return_value=[group_row]),
        patch("app.routers.groups.GroupService.find_user_id_by_username", return_value=99),
        patch("app.routers.groups.GroupService.add_member") as add_member,
        patch("app.routers.groups.GroupService.list_group_members", return_value=[]),
        patch("app.routers.groups.GroupService.list_group_posts", return_value=[]),
    ):
        r = auth_client.post("/groups/3/members", data={"username": "friend"}, follow_redirects=False)
    assert r.status_code == 303
    assert "/groups/3" in (r.headers.get("location") or "")
    add_member.assert_called_once_with(group_id=3, user_id=99, role="member")
