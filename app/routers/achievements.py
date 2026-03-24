"""
Used for: Achievements routes.
Information inside: Catalog + earned achievements for the signed-in user.
"""

from fastapi import APIRouter, Depends, Request
from mysql.connector import Error as MySQLError
from starlette.templating import Jinja2Templates

from app.services.achievement_service import AchievementService
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["achievements"])
templates = Jinja2Templates(directory="app/templates")


@router.get("/achievements")
def achievements_page(request: Request, current_user: dict = Depends(get_current_user)):
    error = None
    definitions: list = []
    earned_by_def: dict[int, dict] = {}

    try:
        definitions = AchievementService.list_definitions()
        for row in AchievementService.list_user_achievements(current_user["user_id"], limit=100):
            earned_by_def[row["achievement_def_id"]] = row
    except MySQLError as exc:
        error = f"Could not load achievements: {exc.msg}"

    items = []
    for d in definitions:
        eid = d["achievement_def_id"]
        earned = earned_by_def.get(eid)
        items.append(
            {
                "code": d["code"],
                "title": d["title"],
                "description": d["description"],
                "earned": earned is not None,
                "achieved_at": earned["achieved_at"] if earned else None,
            }
        )

    return templates.TemplateResponse(
        request=request,
        name="achievements.html",
        context={
            "request": request,
            "title": "Achievements",
            "items": items,
            "error": error,
        },
    )
