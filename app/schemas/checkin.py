"""
Used for: Daily check-in schema definitions.
Information inside: Placeholder Pydantic models for check-in create/update and return payloads.
"""

from datetime import date
from typing import Literal, Optional

from pydantic import BaseModel


class CheckinUpsertRequest(BaseModel):
    record_date: date
    eating_quality: Literal["poor", "average", "good"]
    energy_level: Literal["low", "medium", "high"]
    adherence_to_plan: Literal["poor", "average", "good"]
    notes: Optional[str] = None


class CheckinRow(BaseModel):
    checkin_id: int
    user_id: int
    record_date: date
    eating_quality: Literal["poor", "average", "good"]
    energy_level: Literal["low", "medium", "high"]
    adherence_to_plan: Literal["poor", "average", "good"]
    notes: Optional[str] = None

