"""Workout routes (WorkoutService mocked)."""

from unittest.mock import patch


def test_workouts_requires_authentication(client):
    r = client.get("/workouts")
    assert r.status_code == 401


def test_workouts_page_loads(auth_client):
    with patch("app.routers.workouts.WorkoutService.list_logs", return_value=[]), patch(
        "app.routers.workouts.WorkoutService.list_exercise_types", return_value=[]
    ):
        r = auth_client.get("/workouts")
    assert r.status_code == 200
    assert "Workouts" in r.text


def test_workouts_add_redirects(auth_client):
    with patch("app.routers.workouts.WorkoutService.log_workout") as log:
        r = auth_client.post(
            "/workouts/add",
            data={
                "exercise_id": "1",
                "log_date": "2026-04-01",
                "duration_minutes": "30",
                "notes": "",
            },
            follow_redirects=False,
        )
    assert r.status_code == 303
    assert r.headers.get("location", "").endswith("/workouts")
    log.assert_called_once()
