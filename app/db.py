import mysql.connector
from typing import Any, Optional


def get_db_connection() -> Optional[Any]:
    """
    Creates and returns a MySQL database connection.
    All routes/services should use this function to connect to the DB.
    """
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="sank@678",  # replace with your password
        database="fitness_tracker"
    )

