from fastapi import APIRouter, Request, Form
from fastapi.templating import Jinja2Templates
from fastapi.responses import RedirectResponse
from app.services.metric_service import MetricService

router = APIRouter()
templates = Jinja2Templates(directory="app/templates")

@router.get("/metrics")
async def metrics_page(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse(url="/")
    user_id = request.session.get("user_id")
    metrics = MetricService.get_all(user_id)
    return templates.TemplateResponse(
        request=request,
        name="metrics.html",
        context={"metrics": metrics}
    )

@router.post("/metrics/add")
async def add_metric(
    request: Request,
    record_date: str = Form(...),
    weight_lbs: float = Form(...),
    steps: int = Form(...),
    sleep_hours: float = Form(...),
    water_intake_cups: float = Form(...)
):
    user_id = request.session.get("user_id")
    MetricService.add(user_id, record_date, weight_lbs, steps, sleep_hours, water_intake_cups)
    return RedirectResponse(url="/metrics", status_code=303)

@router.post("/metrics/delete/{metric_id}")
async def delete_metric(request: Request, metric_id: int):
    user_id = request.session.get("user_id")
    MetricService.delete(metric_id, user_id)
    return RedirectResponse(url="/metrics", status_code=303)
