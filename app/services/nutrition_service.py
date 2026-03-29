from app.db import get_db_connection

class NutritionService:

    @staticmethod
    def get_all(user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM nutrition_logs WHERE user_id = %s ORDER BY log_date DESC",
            (user_id,)
        )
        logs = cursor.fetchall()
        conn.close()
        return logs

    @staticmethod
    def add(user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc(
            "sp_log_nutrition_entry",
            (user_id, log_date, meal_type, food_item, calories, protein_g or 0, carbs_g or 0, fat_g or 0)
        )
        conn.commit()
        conn.close()

    @staticmethod
    def delete(nutrition_id: int, user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc(
            "sp_delete_nutrition_entry",
            (nutrition_id, user_id)
        )
        conn.commit()
        conn.close()