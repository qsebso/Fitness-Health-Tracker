"""
Used for: Achievements business logic.
Information inside: Catalog + earned rows via stored procedures (definitions vs user_achievements).
"""

from datetime import datetime, timezone
from typing import Any

from app.db import get_db_connection


class AchievementService:
    """Stored-procedure-backed achievement catalog and earned list."""

    @staticmethod
    def list_definitions() -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_list_achievement_definitions", ())
            rows: list[dict[str, Any]] = []
            for result in cursor.stored_results():
                rows = list(result.fetchall())
                break
            return rows
        finally:
            conn.close()

    @staticmethod
    def list_user_achievements(user_id: int, limit: int = 50) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_achievements", (user_id, limit))
            rows: list[dict[str, Any]] = []
            for result in cursor.stored_results():
                rows = list(result.fetchall())
                break
            return rows
        finally:
            conn.close()

    @staticmethod
    def grant_by_code(user_id: int, code: str, achieved_at: datetime | None = None) -> None:
        """Idempotent grant when rules detect completion (app or batch job)."""
        conn = get_db_connection()
        try:
            cursor = conn.cursor(buffered=True)
            when = achieved_at or datetime.now(timezone.utc).replace(tzinfo=None)
            cursor.callproc(
                "sp_grant_user_achievement_by_code",
                (user_id, code, when),
            )
            for result in cursor.stored_results():
                result.fetchall()
            conn.commit()
        finally:
            conn.close()
