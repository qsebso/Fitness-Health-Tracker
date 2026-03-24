"""
Used for: Database connection helpers.
Information inside: Placeholder functions for creating a DB engine/connection.
"""

from typing import Any

import mysql.connector
from mysql.connector.connection import MySQLConnection

from app.config import settings


def get_db_connection() -> Any:
    """Return a live MySQL connection for raw SQL operations."""
    return mysql.connector.connect(
        host=settings.mysql_host,
        port=settings.mysql_port,
        user=settings.mysql_user,
        password=settings.mysql_password,
        database=settings.mysql_database,
        autocommit=False,
    )

