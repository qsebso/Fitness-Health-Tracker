"""Daily metrics routes (MetricService mocked)."""

from unittest.mock import patch


def test_metrics_requires_authentication(client):
    r = client.get("/metrics")
    assert r.status_code == 401


def test_metrics_page_loads(auth_client):
    with patch("app.routers.metrics.MetricService.list_metrics", return_value=[]):
        r = auth_client.get("/metrics")
    assert r.status_code == 200
    assert "Daily Metrics" in r.text


def test_metrics_add_redirects_after_save(auth_client):
    with patch("app.routers.metrics.MetricService.upsert_metric") as upsert:
        r = auth_client.post(
            "/metrics/add",
            data={
                "record_date": "2026-04-01",
                "weight_lbs": "180",
                "steps": "5000",
                "sleep_hours": "7",
                "water_intake_cups": "8",
            },
            follow_redirects=False,
        )
    assert r.status_code == 303
    assert r.headers.get("location", "").endswith("/metrics")
    upsert.assert_called_once()
