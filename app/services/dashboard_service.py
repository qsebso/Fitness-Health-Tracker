"""
Used for: Dashboard aggregation logic.
Information inside: Pulls recent rows via existing procedure-backed services + progress_snapshots read.
"""

from typing import Any

from app.db import get_db_connection
from app.services.achievement_service import AchievementService
from app.services.checkin_service import CheckinService
from app.services.goal_service import GoalService
from app.services.group_service import GroupService
from app.services.metric_service import MetricService
from app.services.nutrition_service import NutritionService
from app.services.workout_service import WorkoutService


class DashboardService:
    """Build dashboard context from multiple domains (all DB access via procedures)."""

    @staticmethod
    def list_progress_snapshots(user_id: int, limit: int = 7) -> list[dict[str, Any]]:
        conn = get_db_connection()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc("sp_get_user_progress_snapshots", (user_id, limit))
            for result in cursor.stored_results():
                return list(result.fetchall())
            return []
        finally:
            conn.close()

    @staticmethod
    def build(user_id: int) -> dict[str, Any]:
        uid = int(user_id)
        data: dict[str, Any] = {
            "checkins": [],
            "metrics": [],
            "goals": [],
            "workouts": [],
            "nutrition": [],
            "groups": [],
            "achievements": [],
            "snapshots": [],
        }
        loaders = (
            ("checkins", lambda: CheckinService.list_checkins(uid, 5)),
            ("metrics", lambda: MetricService.list_metrics(uid, 5)),
            ("goals", lambda: GoalService.list_goals(uid)[:8]),
            ("workouts", lambda: WorkoutService.list_logs(uid, 5)),
            ("nutrition", lambda: NutritionService.list_logs(uid, 5)),
            ("groups", lambda: GroupService.list_user_groups(uid)),
            ("achievements", lambda: AchievementService.list_user_achievements(uid, 6)),
            ("snapshots", lambda: DashboardService.list_progress_snapshots(uid, 7)),
        )
        for key, fn in loaders:
            try:
                data[key] = fn()
            except Exception:
                data[key] = []
        active = [g for g in data["goals"] if g.get("status") == "active"]
        data["active_goal_count"] = len(active)
        data["group_count"] = len(data["groups"])
        return data
