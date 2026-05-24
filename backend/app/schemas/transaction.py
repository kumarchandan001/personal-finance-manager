"""FINTELIA — Transaction Schemas"""
import uuid
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field


class TransactionBase(BaseModel):
    amount: Decimal = Field(..., gt=0, max_digits=12, decimal_places=2)
    currency: str = "INR"
    category: str
    subcategory: str | None = None
    description: str | None = None
    transaction_type: str  # income / expense
    payment_method: str | None = None
    merchant: str | None = None
    emotional_tag: str | None = None
    is_recurring: bool = False
    transaction_date: datetime


class TransactionCreate(TransactionBase):
    pass


class TransactionUpdate(BaseModel):
    amount: Decimal | None = Field(None, gt=0, max_digits=12, decimal_places=2)
    category: str | None = None
    subcategory: str | None = None
    description: str | None = None
    transaction_type: str | None = None
    payment_method: str | None = None
    merchant: str | None = None
    emotional_tag: str | None = None
    is_recurring: bool | None = None
    transaction_date: datetime | None = None


class TransactionResponse(TransactionBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime | None = None

    model_config = {"from_attributes": True}


class TransactionSummary(BaseModel):
    total_income: Decimal = Decimal("0")
    total_expense: Decimal = Decimal("0")
    net: Decimal = Decimal("0")
    transaction_count: int = 0
