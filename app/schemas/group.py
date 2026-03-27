"""
Used for: Support group schema definitions.
Information inside: Pydantic models for support group create/list/detail payloads.
"""

from pydantic import BaseModel, Field


class GroupCreateRequest(BaseModel):
    group_name: str = Field(min_length=3, max_length=255)
    description: str | None = None


class UserGroupRow(BaseModel):
    group_id: int
    group_name: str
    role: str


class GroupDetailContext(BaseModel):
    group_id: int
    group_name: str
    role: str
