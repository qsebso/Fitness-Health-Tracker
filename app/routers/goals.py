"""
Used for: Goal routes.
Information inside: Goal CRUD backed by goal stored procedures.
"""

from datetime import date
from decimal import Decimal

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error as MySQLError
from starlette import status
from starlette.templating import Jinja2Templates

from app.services.goal_service import GoalService
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["goals"])
templates = Jinja2Templates(directory="app/templates")


@router.get("/goals")
def goals_page(request: Request, current_user: dict = Depends(get_current_user)):
    error = None
    goals: list = []
    try:
        goals = GoalService.list_goals(current_user["user_id"])
    except MySQLError as exc:
        error = f"Could not load goals: {exc.msg}"

    return templates.TemplateResponse(
        request=request,
        name="goals.html",
        context={
            "request": request,
            "title": "Goals",
            "goals": goals,
            "error": error,
        },
    )


@router.post("/goals/add")
def add_goal(
    request: Request,
    goal_type: str = Form(...),
    target_value: float = Form(...),
    start_date: str = Form(...),
    end_date: str = Form(""),
    status: str = Form(...),
    current_user: dict = Depends(get_current_user),
):
    try:
        end_d = date.fromisoformat(end_date.strip()) if end_date and end_date.strip() else None
        GoalService.create_goal(
            user_id=current_user["user_id"],
            goal_type=goal_type,
            target_value=Decimal(str(target_value)),
            start_date=date.fromisoformat(start_date.strip()),
            end_date=end_d,
            status=status,
        )
        return RedirectResponse(url="/goals", status_code=status.HTTP_303_SEE_OTHER)
    except (ValueError, MySQLError) as exc:
        try:
            goals = GoalService.list_goals(current_user["user_id"])
        except MySQLError:
            goals = []
        return templates.TemplateResponse(
            request=request,
            name="goals.html",
            context={
                "request": request,
                "title": "Goals",
                "goals": goals,
                "error": f"Could not add goal: {getattr(exc, 'msg', str(exc))}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )


@router.post("/goals/delete/{goal_id}")
def delete_goal(
    goal_id: int,
    current_user: dict = Depends(get_current_user),
):
    try:
        GoalService.delete_goal(goal_id, current_user["user_id"])
    except MySQLError:
        pass
    return RedirectResponse(url="/goals", status_code=status.HTTP_303_SEE_OTHER)


@router.post("/goals/update-status/{goal_id}")
def update_goal_status(
    goal_id: int,
    status: str = Form(...),
    current_user: dict = Depends(get_current_user),
):
    try:
        GoalService.update_status(goal_id, current_user["user_id"], status)
    except MySQLError:
        pass
    return RedirectResponse(url="/goals", status_code=status.HTTP_303_SEE_OTHER)
