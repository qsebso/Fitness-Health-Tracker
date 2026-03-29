from app.db import get_db_connection

class MetricService:

    @staticmethod
    def get_all(user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT * FROM daily_metrics WHERE user_id = %s ORDER BY record_date DESC",
            (user_id,)
        )
        metrics = cursor.fetchall()
        conn.close()
        return metrics

    @staticmethod
    def add(user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.callproc(
            "sp_upsert_daily_metric",
            (user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups)
        )
        conn.commit()
        conn.close()

    @staticmethod
    def delete(metric_id: int, user_id: int):
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "DELETE FROM daily_metrics WHERE metric_id = %s AND user_id = %s",
            (metric_id, user_id)
        )
        conn.commit()
        conn.close()