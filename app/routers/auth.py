<<<<<<< HEAD
from fastapi import APIRouter, Request, Form
from fastapi.templating import Jinja2Templates
from fastapi.responses import RedirectResponse
from app.db import get_db_connection

router = APIRouter()
templates = Jinja2Templates(directory="app/templates")

@router.get("/")
async def login_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="login.html"
    )

@router.post("/login")
async def login(
    request: Request,
    username: str = Form(...),
    password: str = Form(...)
):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT * FROM User WHERE email = %s AND password = %s",
        (username, password)
    )
    user = cursor.fetchone()
    conn.close()

    if user:
        request.session["user_id"] = user["user_id"]
        request.session["name"] = user["first_name"]
        return RedirectResponse(url="/dashboard", status_code=303)
    else:
        return templates.TemplateResponse(
            request=request,
            name="login.html",
            context={"error": "Wrong email or password!"}
        )

@router.get("/register")
async def register_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="register.html"
    )

@router.post("/register")
async def register(
    request: Request,
    first_name: str = Form(...),
    last_name: str = Form(...),
    email: str = Form(...),
    password: str = Form(...)
):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO User (first_name, last_name, email, password) VALUES (%s, %s, %s, %s)",
        (first_name, last_name, email, password)
    )
    conn.commit()
    conn.close()
    return RedirectResponse(url="/", status_code=303)

@router.get("/dashboard")
async def dashboard(request: Request):
    if not request.session.get("user_id"):
        return RedirectResponse(url="/")
    name = request.session.get("name")
    return templates.TemplateResponse(
        request=request,
        name="dashboard.html",
        context={"name": name}
    )

@router.get("/logout")
async def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url="/")
=======
"""
Used for: Authentication routes (register/login/logout).
Information inside: Placeholder endpoints that will call `AuthService`.
"""

# TODO: Implement FastAPI routes for authentication.

>>>>>>> 8be1315 (inital commit)
