"""
Used for: Achievement unlock rules (app-side evaluation).
Information inside: Maps `achievement_definitions.code` to checks; grants via `sp_grant_user_achievement_by_code`.
"""

from datetime import date, datetime, timedelta
from typing import Any

from app.services.achievement_service import AchievementService
from app.services.metric_service import MetricService
from app.services.nutrition_service import NutritionService
from app.services.workout_service import WorkoutService


def _as_date(value: Any) -> date:
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, date):
        return value
    return date.fromisoformat(str(value)[:10])


def _last_n_days_all_steps_10k(user_id: int, n: int = 5) -> bool:
    rows = MetricService.list_metrics(user_id, limit=60)
    by_date: dict[date, int] = {}
    for r in rows:
        by_date[_as_date(r["record_date"])] = int(r["steps"])
    d = date.today()
    for i in range(n):
        need = d - timedelta(days=i)
        if by_date.get(need, 0) < 10_000:
            return False
    return True


def _last_n_days_hydration(user_id: int, n: int = 14, min_cups: float = 8.0) -> bool:
    rows = MetricService.list_metrics(user_id, limit=60)
    by_date: dict[date, float] = {}
    for r in rows:
        by_date[_as_date(r["record_date"])] = float(r["water_intake_cups"])
    d = date.today()
    for i in range(n):
        need = d - timedelta(days=i)
        if by_date.get(need, 0.0) < min_cups:
            return False
    return True


def _last_n_days_have_nutrition_log(user_id: int, n: int = 14) -> bool:
    rows = NutritionService.list_logs(user_id, limit=400)
    dates: set[date] = set()
    for r in rows:
        dates.add(_as_date(r["log_date"]))
    d = date.today()
    for i in range(n):
        if (d - timedelta(days=i)) not in dates:
            return False
    return True


def _yoga_workout_count(user_id: int) -> int:
    rows = WorkoutService.list_logs(user_id, limit=500)
    return sum(
        1
        for r in rows
        if str(r.get("exercise_name") or "").strip().lower() == "yoga"
    )


def evaluate_and_grant(user_id: int) -> None:
    """Run all rules; grants are idempotent in the database."""
    uid = int(user_id)
    if _last_n_days_all_steps_10k(uid, 5):
        AchievementService.grant_by_code(uid, "steps_streak_5")
    if _last_n_days_have_nutrition_log(uid, 14):
        AchievementService.grant_by_code(uid, "meal_prep_14")
    if _yoga_workout_count(uid) >= 20:
        AchievementService.grant_by_code(uid, "yoga_20")
    if _last_n_days_hydration(uid, 14, 8.0):
        AchievementService.grant_by_code(uid, "hydration_god")
