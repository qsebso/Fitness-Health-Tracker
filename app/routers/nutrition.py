"""
Used for: Nutrition CRUD routes.
Information inside: Placeholder endpoints for meal/nutrition logging.
"""

from fastapi import APIRouter, Request, Form
from fastapi.templating import Jinja2Templates
from fastapi.responses import RedirectResponse
from app.services.nutrition_service import NutritionService

router = APIRouter()
templates = Jinja2Templates(directory="app/templates")

@router.get("/nutrition")
async def nutrition_page(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse(url="/")
    user_id = request.session.get("user_id")
    logs = NutritionService.get_all(user_id)
    return templates.TemplateResponse(
        request=request,
        name="nutrition.html",
        context={"logs": logs}
    )

@router.post("/nutrition/add")
async def add_nutrition(
    request: Request,
    log_date: str = Form(...),
    meal_type: str = Form(...),
    food_item: str = Form(...),
    calories: float = Form(...),
    protein_g: float = Form(None),
    carbs_g: float = Form(None),
    fat_g: float = Form(None)
):
    user_id = request.session.get("user_id")
    NutritionService.add(user_id, log_date, meal_type, food_item, calories, protein_g, carbs_g, fat_g)
    return RedirectResponse(url="/nutrition", status_code=303)

@router.post("/nutrition/delete/{nutrition_id}")
async def delete_nutrition(request: Request, nutrition_id: int):
    NutritionService.delete(nutrition_id)
    return RedirectResponse(url="/nutrition", status_code=303)



