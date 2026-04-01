"""Daily check-in routes (CheckinService mocked)."""

from unittest.mock import patch


def test_checkins_requires_authentication(client):
    r = client.get("/checkins")
    assert r.status_code == 401


def test_checkins_page_loads(auth_client):
    with patch("app.routers.checkins.CheckinService.list_checkins", return_value=[]):
        r = auth_client.get("/checkins")
    assert r.status_code == 200
    assert "Check" in r.text


def test_checkins_submit_redirects(auth_client):
    with patch("app.routers.checkins.CheckinService.upsert_checkin") as upsert:
        r = auth_client.post(
            "/checkins",
            data={
                "record_date": "2026-04-01",
                "eating_quality": "good",
                "energy_level": "high",
                "adherence_to_plan": "good",
                "notes": "",
            },
            follow_redirects=False,
        )
    assert r.status_code == 303
    assert r.headers.get("location", "").endswith("/checkins")
    upsert.assert_called_once()
