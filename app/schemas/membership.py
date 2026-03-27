"""
Used for: Group membership schema definitions.
Information inside: Placeholder Pydantic models for membership add/remove/list operations.
"""

from pydantic import BaseModel, Field


class GroupMemberRow(BaseModel):
    user_id: int
    username: str
    role: str


class GroupAddMemberRequest(BaseModel):
    username: str = Field(min_length=1, max_length=255)


class GroupRemoveMemberRequest(BaseModel):
    user_id: int = Field(gt=0)
