"""FINTELIA — Budgets Router (Phase 2)"""
import uuid
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import get_db
from app.api.dependencies import get_current_user_id
from app.services.budget_service import BudgetService
from app.schemas.budget import BudgetCreate, BudgetUpdate, BudgetResponse
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/budgets", tags=["Budgets"])


@router.get("/overview")
async def budget_overview(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Aggregated budget overview with total utilization."""
    return await BudgetService(db).get_overview(user_id)


@router.get("/progress")
async def budget_progress(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Per-budget progress with remaining days, projections, and status."""
    return await BudgetService(db).get_progress(user_id)


@router.post("/", response_model=BudgetResponse, status_code=201)
async def create_budget(
    data: BudgetCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await BudgetService(db).create(user_id, data)


@router.get("/", response_model=list[BudgetResponse])
async def list_budgets(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await BudgetService(db).list_by_user(user_id)


@router.get("/{budget_id}", response_model=BudgetResponse)
async def get_budget(
    budget_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await BudgetService(db).get_by_id(budget_id, user_id)


@router.put("/{budget_id}", response_model=BudgetResponse)
async def update_budget(
    budget_id: uuid.UUID,
    data: BudgetUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    return await BudgetService(db).update(budget_id, user_id, data)


@router.delete("/{budget_id}", response_model=MessageResponse)
async def delete_budget(
    budget_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    await BudgetService(db).delete(budget_id, user_id)
    return MessageResponse(message="Budget deleted successfully")
