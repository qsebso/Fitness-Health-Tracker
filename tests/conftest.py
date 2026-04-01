"""Shared pytest fixtures for HTTP client tests (services mocked; no live MySQL required)."""

from __future__ import annotations

from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from app.main import app


def sample_user_profile(*, user_id: int = 1, username: str = "testuser") -> dict:
    return {
        "user_id": user_id,
        "username": username,
        "email": f"{username}@example.com",
        "first_name": "Test",
        "last_name": "User",
    }


@pytest.fixture
def client() -> TestClient:
    return TestClient(app, raise_server_exceptions=True)


@pytest.fixture
def auth_client(client: TestClient) -> TestClient:
    """Logged-in TestClient (AuthService.authenticate_user + get_user_by_id mocked)."""
    profile = sample_user_profile()
    auth_slice = {
        "user_id": profile["user_id"],
        "username": profile["username"],
        "email": profile["email"],
    }
    with (
        patch("app.routers.auth.AuthService.authenticate_user", return_value=auth_slice),
        patch("app.utils.dependencies.AuthService.get_user_by_id", return_value=profile),
    ):
        r = client.post("/login", data={"username": profile["username"], "password": "x"}, follow_redirects=False)
        assert r.status_code == 303, r.text
        yield client
