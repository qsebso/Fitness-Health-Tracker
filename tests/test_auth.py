"""Auth and session behavior via TestClient (AuthService mocked)."""

from unittest.mock import patch

from tests.conftest import sample_user_profile


def test_root_redirects_to_login_when_unauthenticated(client):
    r = client.get("/", follow_redirects=False)
    assert r.status_code == 303
    assert r.headers["location"] == "/login"


def test_login_page_renders(client):
    r = client.get("/login")
    assert r.status_code == 200
    assert "Login" in r.text


def test_register_page_renders(client):
    r = client.get("/register")
    assert r.status_code == 200
    assert "Register" in r.text


def test_login_invalid_credentials(client):
    with patch("app.routers.auth.AuthService.authenticate_user", return_value=None):
        r = client.post("/login", data={"username": "nope", "password": "bad"})
    assert r.status_code == 401
    assert "Invalid username or password" in r.text


def test_login_success_sets_session(client):
    profile = sample_user_profile()
    auth = {"user_id": profile["user_id"], "username": profile["username"], "email": profile["email"]}
    with patch("app.routers.auth.AuthService.authenticate_user", return_value=auth):
        r = client.post("/login", data={"username": profile["username"], "password": "x"}, follow_redirects=False)
    assert r.status_code == 303
    assert r.headers.get("location") in ("/", "http://testserver/")


def test_register_rejects_bad_date(client):
    r = client.post(
        "/register",
        data={
            "username": "u1",
            "email": "u1@e.com",
            "password": "password1",
            "first_name": "A",
            "last_name": "B",
            "date_of_birth": "not-a-date",
            "gender": "other",
            "height_inches": "70",
        },
    )
    assert r.status_code == 400
    assert "YYYY-MM-DD" in r.text


def test_register_success_redirects(client):
    profile = sample_user_profile(user_id=42, username="newu")
    with (
        patch("app.routers.auth.AuthService.register_user", return_value=42),
        patch("app.main.evaluate_and_grant"),
        patch("app.main.DashboardService.build", return_value={"snapshots": []}),
        patch("app.utils.dependencies.AuthService.get_user_by_id", return_value=profile),
    ):
        r = client.post(
            "/register",
            data={
                "username": "newu",
                "email": "newu@e.com",
                "password": "password1",
                "first_name": "A",
                "last_name": "B",
                "date_of_birth": "2000-01-15",
                "gender": "other",
                "height_inches": "70",
            },
            follow_redirects=False,
        )
    assert r.status_code == 303
    assert r.headers.get("location") in ("/", "http://testserver/")


def test_logout_clears_session(auth_client):
    r = auth_client.post("/logout", follow_redirects=False)
    assert r.status_code == 303
    assert "/login" in (r.headers.get("location") or "")
    r2 = auth_client.get("/", follow_redirects=False)
    assert r2.status_code == 303
    assert r2.headers["location"] == "/login"
