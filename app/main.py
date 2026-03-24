"""
Used for: FastAPI application entrypoint.
Information inside: Creates the FastAPI `app` instance and wires in routers/templates.
"""

from fastapi import FastAPI, Request
from fastapi.responses import RedirectResponse
from starlette import status
from starlette.middleware.sessions import SessionMiddleware
from starlette.staticfiles import StaticFiles
from starlette.templating import Jinja2Templates

from app.config import settings
from app.routers.achievements import router as achievements_router
from app.routers.auth import router as auth_router
from app.routers.checkins import router as checkins_router

app = FastAPI(title="Fitness Trend Tracking System")
app.add_middleware(SessionMiddleware, secret_key=settings.session_secret_key)
app.mount("/static", StaticFiles(directory="app/static"), name="static")
templates = Jinja2Templates(directory="app/templates")

app.include_router(auth_router)
app.include_router(checkins_router)
app.include_router(achievements_router)


@app.get("/")
def home(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse(url="/login", status_code=status.HTTP_303_SEE_OTHER)
    return templates.TemplateResponse(
        request=request,
        name="dashboard.html",
        context={"request": request, "title": "Dashboard"},
    )

