<<<<<<< HEAD
import mysql.connector
=======
"""
Used for: Database connection helpers.
Information inside: Placeholder functions for creating a DB engine/connection.
"""

>>>>>>> 8be1315 (inital commit)
from typing import Any, Optional


def get_db_connection() -> Optional[Any]:
    """
<<<<<<< HEAD
    Creates and returns a MySQL database connection.
    All routes/services should use this function to connect to the DB.
    """
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="sank@678",  # replace with your password
        database="fitness_tracker"
    )
=======
    TODO: Implement database connection.

    Keep this function as the single place that knows how to connect to MySQL
    (raw SQL / SQLAlchemy Core / ORM—whichever you choose).
    """

    return None
>>>>>>> 8be1315 (inital commit)

