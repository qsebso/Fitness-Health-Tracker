"""
Used for: Daily check-in business logic.
Information inside: Placeholder functions for per-day check-in create/read/update operations.
"""

from datetime import date
from typing import Any

from app.db import get_db_connection


def _consume_procedure_results(cursor) -> None:
    for result in cursor.stored_results():
        result.fetchall()


class CheckinService:
    """Stored-procedure-backed operations for daily check-ins."""

    @staticmethod
    def upsert_checkin(
        user_id: int,
        record_date: date,
        eating_quality: str,
        energy_level: str,
        adherence_to_plan: str,
        notes: str | None,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(buffered=True)
            cursor.callproc(
                "sp_upsert_daily_checkin",
                (
                    user_id,
                    record_date,
                    eating_quality,
                    energy_level,
                    adherence_to_plan,
                    notes,
                ),
            )
            _consume_procedure_results(cursor)
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def list_checkins(user_id: int, limit: int = 14) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_daily_checkins", (user_id, limit))
            rows: list[dict[str, Any]] = []
            for result in cursor.stored_results():
                rows = list(result.fetchall())
                break
            return rows
        finally:
            conn.close()

