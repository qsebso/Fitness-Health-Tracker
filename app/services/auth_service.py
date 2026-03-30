"""
Used for: Authentication business logic.
Information inside: Placeholder functions for user registration, login, and token/session handling.
"""

from datetime import date
from typing import Optional

from app.db import get_db_connection


class AuthService:
    """Auth service backed by stored procedures."""

    @staticmethod
    def register_user(
        username: str,
        email: str,
        password: str,
        first_name: str,
        last_name: str,
        date_of_birth: date,
        gender: str,
        height_inches: int,
    ) -> int:
        conn = get_db_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc(
                "sp_register_user",
                (
                    username,
                    email,
                    password,
                    first_name,
                    last_name,
                    date_of_birth,
                    gender,
                    height_inches,
                ),
            )
            user_id = None
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    user_id = int(row[0])
            conn.commit()
            if user_id is None:
                raise RuntimeError("sp_register_user did not return user_id.")
            return user_id
        finally:
            conn.close()

    @staticmethod
    def authenticate_user(username: str, password: str) -> Optional[dict]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_auth_by_username", (username,))
            user = None
            for result in cursor.stored_results():
                user = result.fetchone()
                break
            if not user:
                return None
            stored = user.get("password")
            if stored is None or password != str(stored):
                return None
            return {
                "user_id": int(user["user_id"]),
                "username": user["username"],
                "email": user["email"],
            }
        finally:
            conn.close()

    @staticmethod
    def get_user_by_id(user_id: int) -> Optional[dict]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_by_id", (user_id,))
            user = None
            for result in cursor.stored_results():
                user = result.fetchone()
                break
            if not user:
                return None
            return {
                "user_id": int(user["user_id"]),
                "username": user["username"],
                "email": user["email"],
                "first_name": user["first_name"],
                "last_name": user["last_name"],
            }
        finally:
            conn.close()

