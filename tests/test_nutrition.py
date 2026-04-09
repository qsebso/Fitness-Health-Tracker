"""Nutrition routes (NutritionService mocked)."""

from unittest.mock import patch


def test_nutrition_requires_authentication(client):
    r = client.get("/nutrition")
    assert r.status_code == 401


def test_nutrition_page_loads(auth_client):
    with patch("app.routers.nutrition.NutritionService.list_logs", return_value=[]):
        r = auth_client.get("/nutrition")
    assert r.status_code == 200
    assert "Nutrition" in r.text


def test_nutrition_add_redirects(auth_client):
    with patch("app.routers.nutrition.NutritionService.log_entry") as log:
        r = auth_client.post(
            "/nutrition/add",
            data={
                "log_date": "2026-04-01",
                "meal_type": "lunch",
                "food_item": "Salad",
                "calories": "400",
                "protein_g": "25",
                "carbs_g": "30",
                "fat_g": "12",
            },
            follow_redirects=False,
        )
    assert r.status_code == 303
    assert r.headers.get("location", "").endswith("/nutrition")
    log.assert_called_once()
