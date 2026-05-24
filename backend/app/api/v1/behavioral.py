import uuid
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.dependencies import get_current_user_id
from app.database.session import get_db
from app.schemas.behavioral import BehavioralAnalyticsResponse
from app.services.behavioral_service import BehavioralService

router = APIRouter(prefix="/behavioral", tags=["Behavioral Analytics"])


@router.get("/summary", response_model=Optional[BehavioralAnalyticsResponse])
async def get_summary(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Get the latest behavioral analytics summary for the authenticated user."""
    service = BehavioralService(db)
    return await service.get_summary(user_id)


@router.post("/analyze", response_model=BehavioralAnalyticsResponse, status_code=status.HTTP_201_CREATED)
async def analyze(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Trigger a new behavioral analysis based on recent transactions."""
    service = BehavioralService(db)
    return await service.analyze(user_id)
