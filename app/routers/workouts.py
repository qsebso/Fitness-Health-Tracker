"""
Used for: Workout logging routes.
Information inside: Workout CRUD backed by workout + exercise_types procedures.
"""

from datetime import date, datetime, time
from decimal import Decimal
from typing import Optional

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error as MySQLError
from starlette import status
from starlette.templating import Jinja2Templates

from app.services.workout_service import WorkoutService
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["workouts"])
templates = Jinja2Templates(directory="app/templates")


def _workout_log_datetime(log_date_str: str) -> datetime:
    d = date.fromisoformat(log_date_str)
    return datetime.combine(d, time(12, 0, 0))


@router.get("/workouts")
def workouts_page(request: Request, current_user: dict = Depends(get_current_user)):
    error = None
    logs: list = []
    exercises: list = []
    try:
        logs = WorkoutService.list_logs(current_user["user_id"], limit=100)
        exercises = WorkoutService.list_exercise_types()
    except MySQLError as exc:
        error = f"Could not load workouts: {exc.msg}"

    return templates.TemplateResponse(
        request=request,
        name="workouts.html",
        context={
            "request": request,
            "title": "Workouts",
            "logs": logs,
            "exercises": exercises,
            "error": error,
        },
    )


@router.post("/workouts/add")
def add_workout(
    request: Request,
    exercise_id: int = Form(...),
    log_date: str = Form(...),
    duration_minutes: int = Form(...),
    calories_burned: Optional[float] = Form(None),
    notes: str = Form(""),
    current_user: dict = Depends(get_current_user),
):
    try:
        log_at = _workout_log_datetime(log_date.strip())
        cb = Decimal(str(calories_burned)) if calories_burned is not None else None
        WorkoutService.log_workout(
            user_id=current_user["user_id"],
            exercise_id=exercise_id,
            log_at=log_at,
            duration_minutes=duration_minutes,
            calories_burned=cb,
            notes=notes.strip() or None,
        )
        return RedirectResponse(url="/workouts", status_code=status.HTTP_303_SEE_OTHER)
    except (ValueError, MySQLError) as exc:
        try:
            logs = WorkoutService.list_logs(current_user["user_id"], limit=100)
            exercises = WorkoutService.list_exercise_types()
        except MySQLError:
            logs = []
            exercises = []
        return templates.TemplateResponse(
            request=request,
            name="workouts.html",
            context={
                "request": request,
                "title": "Workouts",
                "logs": logs,
                "exercises": exercises,
                "error": f"Could not add workout: {getattr(exc, 'msg', str(exc))}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )


@router.post("/workouts/delete/{workout_id}")
def delete_workout(
    workout_id: int,
    current_user: dict = Depends(get_current_user),
):
    try:
        WorkoutService.delete_workout(workout_id, current_user["user_id"])
    except MySQLError:
        pass
    return RedirectResponse(url="/workouts", status_code=status.HTTP_303_SEE_OTHER)
