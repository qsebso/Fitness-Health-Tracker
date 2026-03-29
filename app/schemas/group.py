from fastapi import APIRouter, Request, Form
from fastapi.templating import Jinja2Templates
from fastapi.responses import RedirectResponse
from app.services.goal_service import GoalService

router = APIRouter()
templates = Jinja2Templates(directory="app/templates")

@router.get("/goals")
async def goals_page(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse(url="/")
    user_id = request.session.get("user_id")
    goals = GoalService.get_all(user_id)
    return templates.TemplateResponse(
        request=request,
        name="goals.html",
        context={"goals": goals}
    )

@router.post("/goals/add")
async def add_goal(
    request: Request,
    goal_type: str = Form(...),
    target_value: float = Form(...),
    start_date: str = Form(...),
    end_date: str = Form(None),
    status: str = Form(...)
):
    user_id = request.session.get("user_id")
    GoalService.add(user_id, goal_type, target_value, start_date, end_date, status)
    return RedirectResponse(url="/goals", status_code=303)

@router.post("/goals/delete/{goal_id}")
async def delete_goal(request: Request, goal_id: int):
    user_id = request.session.get("user_id")
    GoalService.delete(goal_id, user_id)
    return RedirectResponse(url="/goals", status_code=303)

@router.post("/goals/update-status/{goal_id}")
async def update_goal_status(
    request: Request,
    goal_id: int,
    status: str = Form(...)
):
    user_id = request.session.get("user_id")
    GoalService.update_status(goal_id, user_id, status)
    return RedirectResponse(url="/goals", status_code=303)