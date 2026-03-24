"""
Used for: Achievement schema definitions.
Information inside: Pydantic models for catalog rows, earned rows, merged UI/API payloads, and grant requests.
"""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class AchievementDefinitionRow(BaseModel):
    """One row from `achievement_definitions` / `sp_list_achievement_definitions`."""

    achievement_def_id: int
    code: str
    title: str
    description: str


class UserAchievementRow(BaseModel):
    """One earned row from `sp_get_user_achievements` (includes joined definition fields)."""

    user_achievement_id: int
    user_id: int
    achievement_def_id: int
    code: str
    title: str
    description: str
    achieved_at: datetime


class AchievementListItem(BaseModel):
    """Catalog entry plus whether the current user has earned it (Achievements page / JSON)."""

    code: str
    title: str
    description: str
    earned: bool
    achieved_at: Optional[datetime] = None


class GrantAchievementByCodeRequest(BaseModel):
    """Payload when app logic or an admin endpoint grants by stable `code`."""

    code: str = Field(min_length=1, max_length=64)
    achieved_at: Optional[datetime] = None


class GrantAchievementByDefIdRequest(BaseModel):
    """Payload when granting by primary key from `achievement_definitions`."""

    achievement_def_id: int = Field(gt=0)
    achieved_at: Optional[datetime] = None
