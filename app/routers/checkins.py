"""
Used for: Daily check-in routes.
Information inside: Placeholder endpoints for creating/viewing/updating daily check-in records.
"""

from datetime import date

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error as MySQLError
from starlette import status
from starlette.templating import Jinja2Templates

from app.schemas.checkin import CheckinUpsertRequest
from app.services.checkin_service import CheckinService
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["checkins"])
templates = Jinja2Templates(directory="app/templates")


@router.get("/checkins")
def checkins_page(request: Request, current_user: dict = Depends(get_current_user)):
    error = None
    rows = []
    try:
        rows = CheckinService.list_checkins(current_user["user_id"], limit=20)
    except MySQLError as exc:
        error = f"Could not load check-ins: {exc.msg}"

    return templates.TemplateResponse(
        request=request,
        name="checkins.html",
        context={
            "request": request,
            "title": "Daily Check-ins",
            "rows": rows,
            "today": date.today().isoformat(),
            "error": error,
        },
    )


@router.post("/checkins")
def checkins_submit(
    request: Request,
    record_date: str = Form(...),
    eating_quality: str = Form(...),
    energy_level: str = Form(...),
    adherence_to_plan: str = Form(...),
    notes: str = Form(""),
    current_user: dict = Depends(get_current_user),
):
    try:
        payload = CheckinUpsertRequest(
            record_date=record_date,
            eating_quality=eating_quality,
            energy_level=energy_level,
            adherence_to_plan=adherence_to_plan,
            notes=notes.strip() or None,
        )
        CheckinService.upsert_checkin(
            user_id=current_user["user_id"],
            record_date=payload.record_date,
            eating_quality=payload.eating_quality,
            energy_level=payload.energy_level,
            adherence_to_plan=payload.adherence_to_plan,
            notes=payload.notes,
        )
        return RedirectResponse(url="/checkins", status_code=status.HTTP_303_SEE_OTHER)
    except (ValueError, MySQLError) as exc:
        rows = []
        try:
            rows = CheckinService.list_checkins(current_user["user_id"], limit=20)
        except MySQLError:
            rows = []
        return templates.TemplateResponse(
            request=request,
            name="checkins.html",
            context={
                "request": request,
                "title": "Daily Check-ins",
                "rows": rows,
                "today": date.today().isoformat(),
                "error": f"Could not save check-in: {getattr(exc, 'msg', str(exc))}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )

