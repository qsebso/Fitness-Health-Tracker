"""
Used for: Goal business logic.
Information inside: Goal CRUD via stored procedures only (no ad-hoc SQL).
"""

from datetime import date
from decimal import Decimal
from typing import Any

from app.db import get_db_connection


def _consume_procedure_results(cursor) -> None:
    """mysql-connector requires reading all result sets after callproc before commit/close."""
    for result in cursor.stored_results():
        result.fetchall()


class GoalService:
    """Stored-procedure-backed goal operations."""

    @staticmethod
    def list_goals(user_id: int) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_goals", (user_id,))
            for result in cursor.stored_results():
                return list(result.fetchall())
            return []
        finally:
            conn.close()

    @staticmethod
    def create_goal(
        user_id: int,
        goal_type: str,
        target_value: Decimal,
        start_date: date,
        end_date: date | None,
        status: str,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(buffered=True)
            cursor.callproc(
                "sp_create_goal",
                (user_id, goal_type, target_value, start_date, end_date, status),
            )
            _consume_procedure_results(cursor)
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def update_status(goal_id: int, user_id: int, status: str) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(buffered=True)
            cursor.callproc(
                "sp_update_goal_status",
                (goal_id, user_id, status),
            )
            _consume_procedure_results(cursor)
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def update_goal(
        goal_id: int,
        user_id: int,
        goal_type: str,
        target_value: Decimal,
        start_date: date,
        end_date: date | None,
        status: str,
    ) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(buffered=True)
            cursor.callproc(
                "sp_update_goal",
                (
                    goal_id,
                    user_id,
                    goal_type,
                    target_value,
                    start_date,
                    end_date,
                    status,
                ),
            )
            _consume_procedure_results(cursor)
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def delete_goal(goal_id: int, user_id: int) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(buffered=True)
            cursor.callproc("sp_delete_goal", (goal_id, user_id))
            _consume_procedure_results(cursor)
            conn.commit()
        finally:
            conn.close()
