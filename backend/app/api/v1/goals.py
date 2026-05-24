"""FINTELIA — Goals Router (Phase 2)"""
import uuid
from decimal import Decimal
from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import get_db
from app.api.dependencies import get_current_user_id
from app.services.goal_service import GoalService
from app.schemas.goal import GoalCreate, GoalUpdate, GoalResponse
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/goals", tags=["Goals"])


class ProgressUpdate(BaseModel):
    amount: Decimal = Field(..., gt=0, max_digits=12, decimal_places=2)


@router.get("/details")
async def list_goals_with_details(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """List all goals with calculated progress details."""
    return await GoalService(db).list_with_details(user_id)


@router.post("/", response_model=GoalResponse, status_code=201)
async def create_goal(
    data: GoalCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await GoalService(db).create(user_id, data)


@router.get("/", response_model=list[GoalResponse])
async def list_goals(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await GoalService(db).list_by_user(user_id)


@router.get("/{goal_id}", response_model=GoalResponse)
async def get_goal(
    goal_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await GoalService(db).get_by_id(goal_id, user_id)


@router.put("/{goal_id}", response_model=GoalResponse)
async def update_goal(
    goal_id: uuid.UUID,
    data: GoalUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await GoalService(db).update(goal_id, user_id, data)


@router.patch("/{goal_id}/progress")
async def update_progress(
    goal_id: uuid.UUID,
    data: ProgressUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Add amount to goal progress."""
    return await GoalService(db).update_progress(goal_id, user_id, data.amount)


@router.delete("/{goal_id}", response_model=MessageResponse)
async def delete_goal(
    goal_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    await GoalService(db).delete(goal_id, user_id)
    return MessageResponse(message="Goal deleted successfully")
