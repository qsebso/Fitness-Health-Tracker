"""Goal routes (GoalService mocked)."""

from unittest.mock import patch


def test_goals_requires_authentication(client):
    r = client.get("/goals")
    assert r.status_code == 401


def test_goals_page_loads(auth_client):
    with patch("app.routers.goals.GoalService.list_goals", return_value=[]):
        r = auth_client.get("/goals")
    assert r.status_code == 200
    assert "Goals" in r.text


def test_goals_add_redirects(auth_client):
    with patch("app.routers.goals.GoalService.create_goal") as create:
        r = auth_client.post(
            "/goals/add",
            data={
                "goal_type": "endurance",
                "target_value": "10",
                "start_date": "2026-04-01",
                "end_date": "2026-06-01",
                "status": "active",
            },
            follow_redirects=False,
        )
    assert r.status_code == 303
    assert r.headers.get("location", "").endswith("/goals")
    create.assert_called_once()


def test_goals_add_rejects_end_before_start(auth_client):
    with patch("app.routers.goals.GoalService.list_goals", return_value=[]):
        r = auth_client.post(
            "/goals/add",
            data={
                "goal_type": "endurance",
                "target_value": "10",
                "start_date": "2026-06-01",
                "end_date": "2026-04-01",
                "status": "active",
            },
        )
    assert r.status_code == 400
    assert "Could not add goal" in r.text
