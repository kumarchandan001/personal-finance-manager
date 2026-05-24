"""FINTELIA — Transactions Router"""
import uuid
from datetime import datetime
from decimal import Decimal

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.session import get_db
from app.api.dependencies import get_current_user_id
from app.services.transaction_service import TransactionService
from app.schemas.transaction import TransactionCreate, TransactionUpdate, TransactionResponse
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/transactions", tags=["Transactions"])


@router.get("/summary")
async def get_summary(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Get income/expense/net summary for the authenticated user."""
    service = TransactionService(db)
    return await service.get_summary(user_id)


@router.get("/categories", response_model=list[str])
async def get_categories(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Get distinct transaction categories for the authenticated user."""
    service = TransactionService(db)
    return await service.get_categories(user_id)


@router.post("/", response_model=TransactionResponse, status_code=201)
async def create_transaction(
    data: TransactionCreate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    service = TransactionService(db)
    return await service.create(user_id, data)


@router.get("/", response_model=list[TransactionResponse])
async def list_transactions(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    category: str | None = None,
    transaction_type: str | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
    min_amount: Decimal | None = None,
    max_amount: Decimal | None = None,
):
    service = TransactionService(db)
    return await service.list_by_user(
        user_id, limit, offset, category, transaction_type,
        date_from, date_to, min_amount, max_amount,
    )


@router.get("/{transaction_id}", response_model=TransactionResponse)
async def get_transaction(
    transaction_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    service = TransactionService(db)
    return await service.get_by_id(transaction_id, user_id)


@router.put("/{transaction_id}", response_model=TransactionResponse)
async def update_transaction(
    transaction_id: uuid.UUID,
    data: TransactionUpdate,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    service = TransactionService(db)
    return await service.update(transaction_id, user_id, data)


@router.delete("/{transaction_id}", response_model=MessageResponse)
async def delete_transaction(
    transaction_id: uuid.UUID,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    service = TransactionService(db)
    await service.delete(transaction_id, user_id)
    return MessageResponse(message="Transaction deleted successfully")
