"""FINTELIA — AI Schemas"""
import uuid
from datetime import datetime
from pydantic import BaseModel

class AIInsightResponse(BaseModel):
    id: uuid.UUID
    insight_type: str
    title: str
    description: str
    confidence_score: float | None = None
    data: dict | None = None
    is_read: bool = False
    is_actionable: bool = True
    created_at: datetime | None = None
    model_config = {"from_attributes": True}

class ChatMessage(BaseModel):
    message: str
    context: dict | None = None

class ChatResponse(BaseModel):
    response: str
    suggestions: list[str] = []
    insights: list[AIInsightResponse] = []
