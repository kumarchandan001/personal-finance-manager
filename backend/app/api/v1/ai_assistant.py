"""FINTELIA — AI Assistant Router (Phase 3)

Real Gemini-powered endpoints for chat, analysis,
summary, recommendations, and categorization.
"""
from __future__ import annotations

import uuid
from pydantic import BaseModel

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.session import get_db
from app.api.dependencies import get_current_user_id
from app.services.ai_assistant_service import AIAssistantService
from app.schemas.ai import ChatMessage, ChatResponse

router = APIRouter(prefix="/ai", tags=["AI Assistant"])


class CategorizeRequest(BaseModel):
    description: str
    merchant: str = ""
    amount: float = 0


@router.post("/chat")
async def chat(
    data: ChatMessage,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """AI finance chat powered by Gemini with user context."""
    return await AIAssistantService(db).chat(user_id, data.message)


@router.post("/analyze-spending")
async def analyze_spending(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Deep AI spending analysis with actionable recommendations."""
    return await AIAssistantService(db).analyze_spending(user_id)


@router.get("/summary")
async def get_summary(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """AI-generated monthly financial narrative."""
    return await AIAssistantService(db).get_summary(user_id)


@router.get("/recommendations")
async def get_recommendations(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Structured AI financial recommendations."""
    return await AIAssistantService(db).get_recommendations(user_id)


@router.post("/categorize")
async def categorize_transaction(
    data: CategorizeRequest,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """AI-powered transaction categorization."""
    return await AIAssistantService(db).categorize_transaction(
        data.description, data.merchant, data.amount
    )
