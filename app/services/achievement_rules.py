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


def _has_n_day_steps_streak(user_id: int, n: int = 5, min_steps: int = 10_000) -> bool:
    """True if metrics include any n consecutive calendar days, each with steps >= min_steps.

    Uses stored metric history, not 'last n days from today', so an older streak still counts.
    """
    rows = MetricService.list_metrics(user_id, limit=120)
    good_days: set[date] = set()
    for r in rows:
        if int(r["steps"]) >= min_steps:
            good_days.add(_as_date(r["record_date"]))
    if len(good_days) < n:
        return False
    for d in sorted(good_days):
        if all((d + timedelta(days=k)) in good_days for k in range(n)):
            return True
    return False


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
    if _has_n_day_steps_streak(uid, 5, 10_000):
        AchievementService.grant_by_code(uid, "steps_streak_5")
    if _last_n_days_have_nutrition_log(uid, 14):
        AchievementService.grant_by_code(uid, "meal_prep_14")
    if _yoga_workout_count(uid) >= 20:
        AchievementService.grant_by_code(uid, "yoga_20")
    if _last_n_days_hydration(uid, 14, 8.0):
        AchievementService.grant_by_code(uid, "hydration_god")
