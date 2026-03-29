from app.db import get_db_connection

class WorkoutService:

    @staticmethod
    def get_all(user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            """SELECT w.*, e.name as exercise_name 
               FROM workout_logs w 
               JOIN exercise_types e ON w.exercise_id = e.exercise_id
               WHERE w.user_id = %s 
               ORDER BY w.log_date DESC""",
            (user_id,)
        )
        logs = cursor.fetchall()
        conn.close()
        return logs

    @staticmethod
    def get_exercises():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM exercise_types ORDER BY name")
        exercises = cursor.fetchall()
        conn.close()
        return exercises

    @staticmethod
    def add(user_id, exercise_id, log_date, duration_minutes, calories_burned, notes):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc(
            "sp_log_workout",
            (user_id, exercise_id, log_date, duration_minutes, calories_burned or 0, notes or "")
        )
        conn.commit()
        conn.close()

    @staticmethod
    def delete(workout_id: int, user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc(
            "sp_delete_workout_log",
            (workout_id, user_id)
        )
        conn.commit()
        conn.close()

