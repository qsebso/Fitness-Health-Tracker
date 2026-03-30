"""
Used for: Nutrition CRUD routes.
Information inside: Meal logging backed by nutrition stored procedures.
"""

from datetime import date, datetime, time
from decimal import Decimal
from typing import Optional

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error as MySQLError
from starlette import status
from starlette.templating import Jinja2Templates

from app.services.nutrition_service import NutritionService
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["nutrition"])
templates = Jinja2Templates(directory="app/templates")


def _meal_log_datetime(log_date_str: str) -> datetime:
    d = date.fromisoformat(log_date_str)
    return datetime.combine(d, time(12, 0, 0))


@router.get("/nutrition")
def nutrition_page(request: Request, current_user: dict = Depends(get_current_user)):
    error = None
    logs: list = []
    try:
        logs = NutritionService.list_logs(current_user["user_id"], limit=100)
    except MySQLError as exc:
        error = f"Could not load nutrition logs: {exc.msg}"

    return templates.TemplateResponse(
        request=request,
        name="nutrition.html",
        context={
            "request": request,
            "title": "Nutrition",
            "logs": logs,
            "error": error,
        },
    )


@router.post("/nutrition/add")
def add_nutrition(
    request: Request,
    log_date: str = Form(...),
    meal_type: str = Form(...),
    food_item: str = Form(...),
    calories: int = Form(...),
    protein_g: Optional[float] = Form(None),
    carbs_g: Optional[float] = Form(None),
    fat_g: Optional[float] = Form(None),
    current_user: dict = Depends(get_current_user),
):
    try:
        log_at = _meal_log_datetime(log_date.strip())
        NutritionService.log_entry(
            user_id=current_user["user_id"],
            log_at=log_at,
            meal_type=meal_type,
            food_item=food_item.strip(),
            calories=int(calories),
            protein_g=Decimal(str(protein_g if protein_g is not None else 0)),
            carbs_g=Decimal(str(carbs_g)) if carbs_g is not None else None,
            fat_g=Decimal(str(fat_g)) if fat_g is not None else None,
        )
        return RedirectResponse(url="/nutrition", status_code=status.HTTP_303_SEE_OTHER)
    except (ValueError, MySQLError) as exc:
        try:
            logs = NutritionService.list_logs(current_user["user_id"], limit=100)
        except MySQLError:
            logs = []
        return templates.TemplateResponse(
            request=request,
            name="nutrition.html",
            context={
                "request": request,
                "title": "Nutrition",
                "logs": logs,
                "error": f"Could not add entry: {getattr(exc, 'msg', str(exc))}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )


@router.post("/nutrition/delete/{nutrition_id}")
def delete_nutrition(
    nutrition_id: int,
    current_user: dict = Depends(get_current_user),
):
    try:
        NutritionService.delete_entry(nutrition_id, current_user["user_id"])
    except MySQLError:
        pass
    return RedirectResponse(url="/nutrition", status_code=status.HTTP_303_SEE_OTHER)
