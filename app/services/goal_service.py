from app.db import get_db_connection

class GoalService:

    @staticmethod
    def get_all(user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM goals WHERE user_id = %s ORDER BY start_date DESC",
            (user_id,)
        )
        goals = cursor.fetchall()
        conn.close()
        return goals

    @staticmethod
    def add(user_id, goal_type, target_value, start_date, end_date, status):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc(
            "sp_create_goal",
            (user_id, goal_type, target_value, start_date, end_date or None, status)
        )
        conn.commit()
        conn.close()

    @staticmethod
    def update_status(goal_id, user_id, status):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc(
            "sp_update_goal_status",
            (goal_id, user_id, status)
        )
        conn.commit()
        conn.close()

    @staticmethod
    def delete(goal_id: int, user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM goals WHERE goal_id = %s AND user_id = %s",
            (goal_id, user_id)
        )
        conn.commit()
        conn.close()