from datetime import date, datetime
from typing import Dict, Optional
import uuid

from pydantic import BaseModel, ConfigDict


class BehavioralAnalyticsBase(BaseModel):
    analysis_type: str
    period_start: date
    period_end: date
    spending_pattern: Optional[Dict] = None
    emotional_spending_score: Optional[float] = None
    impulse_score: Optional[float] = None
    financial_health_score: Optional[float] = None
    behavioral_archetype: Optional[Dict] = None
    recommendations: Optional[Dict] = None


class BehavioralAnalyticsCreate(BehavioralAnalyticsBase):
    pass


class BehavioralAnalyticsResponse(BehavioralAnalyticsBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
