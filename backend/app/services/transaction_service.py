"""FINTELIA — Transaction Service"""
import uuid
from datetime import datetime
from decimal import Decimal

from sqlalchemy import select, func, distinct
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models.transaction import Transaction
from app.schemas.transaction import TransactionCreate, TransactionUpdate


class TransactionService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, user_id: uuid.UUID, data: TransactionCreate) -> Transaction:
        txn = Transaction(user_id=user_id, **data.model_dump())
        self.db.add(txn)
        await self.db.flush()
        return txn

    async def get_by_id(self, txn_id: uuid.UUID, user_id: uuid.UUID) -> Transaction:
        result = await self.db.execute(
            select(Transaction).where(Transaction.id == txn_id, Transaction.user_id == user_id)
        )
        txn = result.scalar_one_or_none()
        if not txn:
            raise NotFoundException("Transaction not found")
        return txn

    async def list_by_user(
        self,
        user_id: uuid.UUID,
        limit: int = 20,
        offset: int = 0,
        category: str | None = None,
        txn_type: str | None = None,
        date_from: datetime | None = None,
        date_to: datetime | None = None,
        min_amount: Decimal | None = None,
        max_amount: Decimal | None = None,
    ) -> list[Transaction]:
        query = select(Transaction).where(Transaction.user_id == user_id)

        if category:
            query = query.where(Transaction.category == category)
        if txn_type:
            query = query.where(Transaction.transaction_type == txn_type)
        if date_from:
            query = query.where(Transaction.transaction_date >= date_from)
        if date_to:
            query = query.where(Transaction.transaction_date <= date_to)
        if min_amount is not None:
            query = query.where(Transaction.amount >= min_amount)
        if max_amount is not None:
            query = query.where(Transaction.amount <= max_amount)

        query = query.order_by(Transaction.transaction_date.desc()).limit(limit).offset(offset)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def update(self, txn_id: uuid.UUID, user_id: uuid.UUID, data: TransactionUpdate) -> Transaction:
        txn = await self.get_by_id(txn_id, user_id)
        for key, value in data.model_dump(exclude_unset=True).items():
            setattr(txn, key, value)
        await self.db.flush()
        return txn

    async def delete(self, txn_id: uuid.UUID, user_id: uuid.UUID) -> None:
        txn = await self.get_by_id(txn_id, user_id)
        await self.db.delete(txn)
        await self.db.flush()

    async def get_summary(self, user_id: uuid.UUID) -> dict:
        """Get income/expense/net summary for the user."""
        # Total income
        income_q = await self.db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "income",
            )
        )
        total_income = income_q.scalar() or Decimal("0")

        # Total expense
        expense_q = await self.db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "expense",
            )
        )
        total_expense = expense_q.scalar() or Decimal("0")

        # Count
        count_q = await self.db.execute(
            select(func.count(Transaction.id)).where(Transaction.user_id == user_id)
        )
        count = count_q.scalar() or 0

        return {
            "total_income": float(total_income),
            "total_expense": float(total_expense),
            "net": float(total_income - total_expense),
            "transaction_count": count,
        }

    async def get_categories(self, user_id: uuid.UUID) -> list[str]:
        """Get distinct transaction categories for the user."""
        result = await self.db.execute(
            select(distinct(Transaction.category)).where(
                Transaction.user_id == user_id
            ).order_by(Transaction.category)
        )
        return [row[0] for row in result.all()]
