"""
Used for: Support group business logic.
Information inside: Placeholder service functions for create/list/get support groups.
"""

from typing import Any

from app.db import get_db_connection


class GroupService:
    """Stored-procedure-backed operations for support groups and memberships."""

    @staticmethod
    def list_user_groups(user_id: int) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_groups", (user_id,))
            rows: list[dict[str, Any]] = []
            for result in cursor.stored_results():
                rows = list(result.fetchall())
                break
            return rows
        finally:
            conn.close()

    @staticmethod
    def create_group(group_name: str, description: str | None, created_by_user_id: int) -> int:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_create_support_group",
                (group_name, description, created_by_user_id),
            )
            group_id = None
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    group_id = int(row[0])
            conn.commit()
            if group_id is None:
                raise RuntimeError("sp_create_support_group did not return group_id.")
            return group_id
        finally:
            conn.close()

    @staticmethod
    def list_group_members(group_id: int) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_group_members", (group_id,))
            rows: list[dict[str, Any]] = []
            for result in cursor.stored_results():
                rows = list(result.fetchall())
                break
            return rows
        finally:
            conn.close()

    @staticmethod
    def add_member(group_id: int, user_id: int, role: str = "member") -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_add_group_member", (group_id, user_id, role))
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def remove_member(group_id: int, user_id: int) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_remove_group_member", (group_id, user_id))
            conn.commit()
        finally:
            conn.close()

    @staticmethod
    def find_user_id_by_username(username: str) -> int | None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_auth_by_username", (username,))
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    return int(row["user_id"])
                break
            return None
        finally:
            conn.close()

    @staticmethod
    def list_group_posts(group_id: int, limit: int = 50) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_group_posts", (group_id, limit))
            rows: list[dict[str, Any]] = []
            for result in cursor.stored_results():
                rows = list(result.fetchall())
                break
            return rows
        finally:
            conn.close()

    @staticmethod
    def create_group_post(group_id: int, user_id: int, content: str) -> None:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_create_group_post", (group_id, user_id, content))
            conn.commit()
        finally:
            conn.close()
