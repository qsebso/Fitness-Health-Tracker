from fastapi import APIRouter, Request, Form
from fastapi.templating import Jinja2Templates
from fastapi.responses import RedirectResponse
from app.services.workout_service import WorkoutService

router = APIRouter()
templates = Jinja2Templates(directory="app/templates")

@router.get("/workouts")
async def workouts_page(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse(url="/")
    user_id = request.session.get("user_id")
    logs = WorkoutService.get_all(user_id)
    exercises = WorkoutService.get_exercises()
    return templates.TemplateResponse(
        request=request,
        name="workouts.html",
        context={"logs": logs, "exercises": exercises}
    )

@router.post("/workouts/add")
async def add_workout(
    request: Request,
    exercise_id: int = Form(...),
    log_date: str = Form(...),
    duration_minutes: int = Form(...),
    calories_burned: float = Form(None),
    notes: str = Form(None)
):
    user_id = request.session.get("user_id")
    WorkoutService.add(user_id, exercise_id, log_date, duration_minutes, calories_burned, notes)
    return RedirectResponse(url="/workouts", status_code=303)

@router.post("/workouts/delete/{workout_id}")
async def delete_workout(request: Request, workout_id: int):
    user_id = request.session.get("user_id")
    WorkoutService.delete(workout_id, user_id)
    return RedirectResponse(url="/workouts", status_code=303)
