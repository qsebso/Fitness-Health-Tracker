"""Pydantic models for registration and login payloads."""

from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class RegisterRequest(BaseModel):
    """Payload for creating a new user account."""

    username: str = Field(min_length=3, max_length=255)
    email: str = Field(min_length=5, max_length=255)
    password: str = Field(min_length=8, max_length=255)
    first_name: str = Field(min_length=1, max_length=255)
    last_name: str = Field(min_length=1, max_length=255)
    date_of_birth: date
    gender: Literal["male", "female", "other"]
    height_inches: int = Field(gt=0, lt=120)


class LoginRequest(BaseModel):
    """Payload for logging in an existing user."""

    username: str = Field(min_length=1, max_length=255)
    password: str = Field(min_length=1, max_length=255)


class AuthUserResponse(BaseModel):
    """Public user fields returned after successful auth lookup."""

    user_id: int
    username: str
    email: str


class AuthMessageResponse(BaseModel):
    """Simple status message response."""

    message: str