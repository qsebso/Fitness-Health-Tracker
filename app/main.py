from fastapi import FastAPI
from starlette.middleware.sessions import SessionMiddleware
from fastapi.staticfiles import StaticFiles
from app.routers import auth, nutrition

app = FastAPI(title="Fitness Trend Tracking System")

app.add_middleware(SessionMiddleware, secret_key="fitness123")
app.mount("/static", StaticFiles(directory="app/static"), name="static")

app.include_router(auth.router)
app.include_router(nutrition.router)