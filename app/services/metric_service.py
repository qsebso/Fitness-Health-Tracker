"""
Used for: Daily metrics business logic.
Information inside: Daily metrics via stored procedures only (no ad-hoc SQL).
"""

from datetime import date
from decimal import Decimal
from typing import Any

from app.db import get_db_connection


class MetricService:
    """Stored-procedure-backed daily_metrics operations."""

    @staticmethod
    def list_metrics(user_id: int, limit: int = 100) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_daily_metrics", (user_id, limit))
            for result in cursor.stored_results():
                return list(result.fetchall())
            return []
        finally:
            conn.close()

    @staticmethod
    def upsert_metric(
        user_id: int,
        record_date: date,
        weight_lbs: Decimal,
        steps: int,
        sleep_hours: Decimal,
        water_intake_cups: Decimal,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_upsert_daily_metric",
                (
                    user_id,
                    record_date,
                    weight_lbs,
                    steps,
                    sleep_hours,
                    water_intake_cups,
                ),
            )
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def delete_metric(metric_id: int, user_id: int) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_delete_daily_metric", (metric_id, user_id))
            conn.commit()
        finally:
            conn.close()
