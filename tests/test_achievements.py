"""Achievements page (AchievementService mocked)."""

from unittest.mock import patch


def test_achievements_requires_authentication(client):
    r = client.get("/achievements")
    assert r.status_code == 401


def test_achievements_page_loads(auth_client):
    definitions = [
        {"achievement_def_id": 1, "code": "a", "title": "T1", "description": "D1"},
    ]
    with patch(
        "app.routers.achievements.AchievementService.list_definitions", return_value=definitions
    ), patch("app.routers.achievements.AchievementService.list_user_achievements", return_value=[]):
        r = auth_client.get("/achievements")
    assert r.status_code == 200
    assert "Achievement" in r.text or "T1" in r.text
