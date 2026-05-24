"""FINTELIA — Goal Schemas"""
import uuid
from datetime import date, datetime
from decimal import Decimal
from pydantic import BaseModel, Field

class GoalBase(BaseModel):
    title: str
    description: str | None = None
    target_amount: Decimal = Field(..., gt=0, max_digits=12, decimal_places=2)
    deadline: date | None = None
    priority: str = "medium"

class GoalCreate(GoalBase):
    pass

class GoalUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    target_amount: Decimal | None = Field(None, gt=0, max_digits=12, decimal_places=2)
    current_amount: Decimal | None = Field(None, ge=0, max_digits=12, decimal_places=2)
    deadline: date | None = None
    priority: str | None = None
    status: str | None = None

class GoalResponse(GoalBase):
    id: uuid.UUID
    user_id: uuid.UUID
    current_amount: Decimal = Decimal("0")
    status: str = "active"
    created_at: datetime | None = None
    model_config = {"from_attributes": True}
