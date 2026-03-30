"""
Used for: Nutrition business logic.
Information inside: Meal logging via stored procedures only (no ad-hoc SQL).
"""

from datetime import datetime
from decimal import Decimal
from typing import Any

from app.db import get_db_connection


class NutritionService:
    """Stored-procedure-backed nutrition log operations."""

    @staticmethod
    def list_logs(user_id: int, limit: int = 100) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_nutrition_logs", (user_id, limit))
            for result in cursor.stored_results():
                return list(result.fetchall())
            return []
        finally:
            conn.close()

    @staticmethod
    def log_entry(
        user_id: int,
        log_at: datetime,
        meal_type: str,
        food_item: str,
        calories: int,
        protein_g: Decimal,
        carbs_g: Decimal | None,
        fat_g: Decimal | None,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_log_nutrition_entry",
                (
                    user_id,
                    log_at,
                    meal_type,
                    food_item,
                    calories,
                    protein_g,
                    carbs_g if carbs_g is not None else None,
                    fat_g if fat_g is not None else None,
                ),
            )
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def update_entry(
        nutrition_id: int,
        user_id: int,
        log_at: datetime,
        meal_type: str,
        food_item: str,
        calories: int,
        protein_g: Decimal,
        carbs_g: Decimal | None,
        fat_g: Decimal | None,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_update_nutrition_entry",
                (
                    nutrition_id,
                    user_id,
                    log_at,
                    meal_type,
                    food_item,
                    calories,
                    protein_g,
                    carbs_g if carbs_g is not None else None,
                    fat_g if fat_g is not None else None,
                ),
            )
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def delete_entry(nutrition_id: int, user_id: int) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_delete_nutrition_entry",
                (nutrition_id, user_id),
            )
            conn.commit()
        finally:
            conn.close()
