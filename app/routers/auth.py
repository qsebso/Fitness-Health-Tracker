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

from datetime import date

from fastapi import APIRouter, Form, Request
from fastapi.responses import RedirectResponse
from mysql.connector import Error as MySQLError
from starlette import status
from starlette.templating import Jinja2Templates

from app.config import settings
from app.services.auth_service import AuthService

router = APIRouter(tags=["auth"])
templates = Jinja2Templates(directory="app/templates")


@router.get("/register")
def register_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="register.html",
        context={"request": request, "title": "Register"},
    )


@router.post("/register")
def register_submit(
    request: Request,
    username: str = Form(...),
    email: str = Form(...),
    password: str = Form(...),
    first_name: str = Form(...),
    last_name: str = Form(...),
    date_of_birth: str = Form(...),
    gender: str = Form(...),
    height_inches: int = Form(...),
):
    try:
        dob = date.fromisoformat(date_of_birth)
    except ValueError:
        return templates.TemplateResponse(
            request=request,
            name="register.html",
            context={"request": request, "title": "Register", "error": "Date of birth must be YYYY-MM-DD."},
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    try:
        user_id = AuthService.register_user(
            username=username.strip(),
            email=email.strip(),
            password=password,
            first_name=first_name.strip(),
            last_name=last_name.strip(),
            date_of_birth=dob,
            gender=gender,
            height_inches=height_inches,
        )
    except MySQLError as exc:
        return templates.TemplateResponse(
            request=request,
            name="register.html",
            context={
                "request": request,
                "title": "Register",
                "error": f"Registration failed ({settings.mysql_user}@{settings.mysql_host}/{settings.mysql_database}): {exc.msg}",
            },
            status_code=status.HTTP_400_BAD_REQUEST,
        )

    request.session["user_id"] = user_id
    request.session["username"] = username
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)


@router.get("/login")
def login_page(request: Request):
    return templates.TemplateResponse(
        request=request,
        name="login.html",
        context={"request": request, "title": "Login"},
    )


@router.post("/login")
def login_submit(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
):
    try:
        user = AuthService.authenticate_user(username.strip(), password)
    except MySQLError as exc:
        return templates.TemplateResponse(
            request=request,
            name="login.html",
            context={
                "request": request,
                "title": "Login",
                "error": f"Login failed ({settings.mysql_user}@{settings.mysql_host}/{settings.mysql_database}): {exc.msg}",
            },
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    if not user:
        return templates.TemplateResponse(
            request=request,
            name="login.html",
            context={"request": request, "title": "Login", "error": "Invalid username or password."},
            status_code=status.HTTP_401_UNAUTHORIZED,
        )

    request.session["user_id"] = user["user_id"]
    request.session["username"] = user["username"]
    return RedirectResponse(url="/", status_code=status.HTTP_303_SEE_OTHER)


@router.post("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url="/login", status_code=status.HTTP_303_SEE_OTHER)

>>>>>>> 8be1315 (inital commit)
