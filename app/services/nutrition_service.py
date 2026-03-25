"""
Used for: Nutrition business logic.
Information inside: Placeholder functions for nutrition/meals CRUD and validation rules.
"""
# TODO: USE THE FOLLOWING PROCEDURES:
# sp_get_user_nutrition_logs
# sp_add_nutrition_log
# sp_update_nutrition_log
# sp_delete_nutrition_log

from app.db import get_db_connection

class NutritionService:

    @staticmethod
    def get_all(user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM Nutrition_Log WHERE user_id = %s ORDER BY log_date DESC",
            (user_id,)
        )
        logs = cursor.fetchall()
        conn.close()
        return logs

    @staticmethod
    def add(user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            """INSERT INTO Nutrition_Log 
            (user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
            (user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g)
        )
        conn.commit()
        conn.close()

    @staticmethod
    def delete(nutrition_id: int):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM Nutrition_Log WHERE nutrition_id = %s",
            (nutrition_id,)
        )
        conn.commit()
        conn.close()

