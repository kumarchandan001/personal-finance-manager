"""FINTELIA - Subscription Schemas"""
import uuid
from datetime import date, datetime
from decimal import Decimal
from pydantic import BaseModel, Field

class SubscriptionBase(BaseModel):
    name: str
    amount: Decimal = Field(..., gt=0, max_digits=12, decimal_places=2)
    billing_cycle: str  # monthly / yearly / weekly
    category: str | None = None
    next_billing_date: date
    is_active: bool = True
    detected_automatically: bool = False

class SubscriptionCreate(SubscriptionBase):
    pass

class SubscriptionUpdate(BaseModel):
    name: str | None = None
    amount: Decimal | None = Field(None, gt=0, max_digits=12, decimal_places=2)
    billing_cycle: str | None = None
    category: str | None = None
    next_billing_date: date | None = None
    is_active: bool | None = None

class SubscriptionResponse(SubscriptionBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime | None = None

    model_config = {"from_attributes": True}
