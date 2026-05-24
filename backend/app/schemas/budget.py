"""FINTELIA — Budget Schemas"""
import uuid
from datetime import date
from decimal import Decimal
from pydantic import BaseModel, Field


class BudgetBase(BaseModel):
    category: str
    amount_limit: Decimal = Field(..., gt=0, max_digits=12, decimal_places=2)
    period: str  # weekly / monthly / yearly
    start_date: date
    end_date: date


class BudgetCreate(BudgetBase):
    pass


class BudgetUpdate(BaseModel):
    category: str | None = None
    amount_limit: Decimal | None = Field(None, gt=0, max_digits=12, decimal_places=2)
    period: str | None = None
    start_date: date | None = None
    end_date: date | None = None
    is_active: bool | None = None


class BudgetResponse(BudgetBase):
    id: uuid.UUID
    user_id: uuid.UUID
    spent_amount: Decimal = Decimal("0")
    is_active: bool = True

    model_config = {"from_attributes": True}

    @property
    def usage_ratio(self) -> float:
        if self.amount_limit > 0:
            return float(self.spent_amount / self.amount_limit)
        return 0.0
