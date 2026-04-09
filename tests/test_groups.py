"""Support group list and create (GroupService mocked)."""

from unittest.mock import patch


def test_groups_requires_authentication(client):
    r = client.get("/groups")
    assert r.status_code == 401


def test_groups_page_loads(auth_client):
    with patch("app.routers.groups.GroupService.list_user_groups", return_value=[]):
        r = auth_client.get("/groups")
    assert r.status_code == 200
    assert "Support Groups" in r.text


def test_groups_create_redirects_to_detail(auth_client):
    with patch("app.routers.groups.GroupService.create_group", return_value=7) as create:
        r = auth_client.post(
            "/groups",
            data={"group_name": "Test Crew", "description": "Unit test group"},
            follow_redirects=False,
        )
    assert r.status_code == 303
    assert "/groups/7" in (r.headers.get("location") or "")
    create.assert_called_once()
