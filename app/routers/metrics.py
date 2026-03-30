"""
Used for: Daily metrics routes.
Information inside: Metrics upsert/list/delete via daily_metrics procedures.
"""

from datetime import date
from decimal import Decimal

from fastapi import APIRouter, Depends, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error as MySQLError
from starlette import status
from starlette.templating import Jinja2Templates

from app.services.metric_service import MetricService
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["metrics"])
templates = Jinja2Templates(directory="app/templates")


@router.get("/metrics")
def metrics_page(request: Request, current_user: dict = Depends(get_current_user)):
    error = None
    metrics: list = []
    try:
        metrics = MetricService.list_metrics(current_user["user_id"], limit=100)
    except MySQLError as exc:
        error = f"Could not load metrics: {exc.msg}"

    return templates.TemplateResponse(
        request=request,
        name="metrics.html",
        context={
            "request": request,
            "title": "Daily Metrics",
            "metrics": metrics,
            "error": error,
        },
    )


@router.post("/metrics/add")
def add_metric(
    request: Request,
    record_date: str = Form(...),
    weight_lbs: float = Form(...),
    steps: int = Form(...),
    sleep_hours: float = Form(...),
    water_intake_cups: float = Form(...),
    current_user: dict = Depends(get_current_user),
):
    try:
        MetricService.upsert_metric(
            user_id=current_user["user_id"],
            record_date=date.fromisoformat(record_date.strip()),
            weight_lbs=Decimal(str(weight_lbs)),
            steps=int(steps),
            sleep_hours=Decimal(str(sleep_hours)),
            water_intake_cups=Decimal(str(water_intake_cups)),
        )
        return RedirectResponse(url="/metrics", status_code=status.HTTP_303_SEE_OTHER)
    except (ValueError, MySQLError) as exc:
        try:
            metrics = MetricService.list_metrics(current_user["user_id"], limit=100)
        except MySQLError:
            metrics = []
        return templates.TemplateResponse(
            request=request,
            name="metrics.html",
            context={
                "request": request,
                "title": "Daily Metrics",
                "metrics": metrics,
                "error": f"Could not save metrics: {getattr(exc, 'msg', str(exc))}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )


@router.post("/metrics/delete/{metric_id}")
def delete_metric(
    metric_id: int,
    current_user: dict = Depends(get_current_user),
):
    try:
        MetricService.delete_metric(metric_id, current_user["user_id"])
    except MySQLError:
        pass
    return RedirectResponse(url="/metrics", status_code=status.HTTP_303_SEE_OTHER)
