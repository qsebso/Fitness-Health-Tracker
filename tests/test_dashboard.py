"""Dashboard route (home) with mocked aggregation."""

from unittest.mock import patch


def test_dashboard_requires_login(client):
    r = client.get("/", follow_redirects=False)
    assert r.status_code == 303
    assert r.headers["location"] == "/login"


def test_dashboard_renders_snapshots_section(auth_client):
    dash = {
        "snapshots": [
            {
                "snapshot_date": "2026-03-29",
                "avg_weight_lbs_7d": 170.5,
                "total_workouts_7d": 5,
                "avg_steps_7d": 10000.0,
                "avg_sleep_hours_7d": 7.5,
                "avg_protein_g_7d": 120.0,
            }
        ],
        "checkins": [],
        "metrics": [],
        "goals": [],
        "workouts": [],
        "nutrition": [],
        "groups": [],
        "achievements": [],
    }
    with patch("app.main.evaluate_and_grant"), patch("app.main.DashboardService.build", return_value=dash):
        r = auth_client.get("/")
    assert r.status_code == 200
    assert "7-day progress" in r.text
    assert "2026-03-29" in r.text
