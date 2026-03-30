"""
Used for: Workout business logic.
Information inside: Workout logging via stored procedures only (no ad-hoc SQL).
"""

from datetime import datetime
from decimal import Decimal
from typing import Any

from app.db import get_db_connection


class WorkoutService:
    """Stored-procedure-backed workout log operations."""

    @staticmethod
    def list_exercise_types() -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_list_exercise_types", ())
            for result in cursor.stored_results():
                return list(result.fetchall())
            return []
        finally:
            conn.close()

    @staticmethod
    def list_logs(user_id: int, limit: int = 100) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_workout_logs", (user_id, limit))
            for result in cursor.stored_results():
                return list(result.fetchall())
            return []
        finally:
            conn.close()

    @staticmethod
    def log_workout(
        user_id: int,
        exercise_id: int,
        log_at: datetime,
        duration_minutes: int,
        calories_burned: Decimal | None,
        notes: str | None,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_log_workout",
                (
                    user_id,
                    exercise_id,
                    log_at,
                    duration_minutes,
                    calories_burned if calories_burned is not None else None,
                    notes,
                ),
            )
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def update_workout(
        workout_id: int,
        user_id: int,
        exercise_id: int,
        log_at: datetime,
        duration_minutes: int,
        calories_burned: Decimal | None,
        notes: str | None,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_update_workout_log",
                (
                    workout_id,
                    user_id,
                    exercise_id,
                    log_at,
                    duration_minutes,
                    calories_burned if calories_burned is not None else None,
                    notes,
                ),
            )
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def delete_workout(workout_id: int, user_id: int) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_delete_workout_log", (workout_id, user_id))
            conn.commit()
        finally:
            conn.close()
