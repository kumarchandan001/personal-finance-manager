"""FINTELIA — Budget Service (Phase 2)

Budget management with progress tracking, spent amount sync,
overspending detection, and overview aggregation.
"""
import uuid
from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models.budget import Budget
from app.models.transaction import Transaction
from app.schemas.budget import BudgetCreate, BudgetUpdate


class BudgetService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create(self, user_id: uuid.UUID, data: BudgetCreate) -> Budget:
        budget = Budget(user_id=user_id, **data.model_dump())
        self.db.add(budget)
        await self.db.flush()
        return budget

    async def get_by_id(self, budget_id: uuid.UUID, user_id: uuid.UUID) -> Budget:
        result = await self.db.execute(
            select(Budget).where(Budget.id == budget_id, Budget.user_id == user_id)
        )
        budget = result.scalar_one_or_none()
        if not budget:
            raise NotFoundException("Budget not found")
        return budget

    async def list_by_user(self, user_id: uuid.UUID, active_only: bool = True) -> list[Budget]:
        query = select(Budget).where(Budget.user_id == user_id)
        if active_only:
            query = query.where(Budget.is_active.is_(True))
        query = query.order_by(Budget.created_at.desc())
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def update(self, budget_id: uuid.UUID, user_id: uuid.UUID, data: BudgetUpdate) -> Budget:
        budget = await self.get_by_id(budget_id, user_id)
        for key, value in data.model_dump(exclude_unset=True).items():
            setattr(budget, key, value)
        await self.db.flush()
        return budget

    async def delete(self, budget_id: uuid.UUID, user_id: uuid.UUID) -> None:
        budget = await self.get_by_id(budget_id, user_id)
        await self.db.delete(budget)
        await self.db.flush()

    # ------------------------------------------------------------------
    # Phase 2: Budget Intelligence
    # ------------------------------------------------------------------

    async def get_overview(self, user_id: uuid.UUID) -> dict:
        """Aggregated budget overview with total limits, spent, and utilization."""
        budgets = await self.list_by_user(user_id, active_only=True)

        # Sync spent amounts from transactions
        await self._sync_spent_amounts(user_id, budgets)

        total_limit = sum(float(b.amount_limit) for b in budgets)
        total_spent = sum(float(b.spent_amount) for b in budgets)
        total_remaining = total_limit - total_spent

        return {
            "total_budget": total_limit,
            "total_spent": total_spent,
            "total_remaining": max(total_remaining, 0),
            "utilization_percent": round(total_spent / total_limit * 100, 1) if total_limit > 0 else 0,
            "budget_count": len(budgets),
            "over_budget_count": sum(1 for b in budgets if float(b.spent_amount) >= float(b.amount_limit)),
        }

    async def get_progress(self, user_id: uuid.UUID) -> list[dict]:
        """Per-budget progress with remaining days and utilization."""
        budgets = await self.list_by_user(user_id, active_only=True)
        await self._sync_spent_amounts(user_id, budgets)

        today = date.today()
        results = []
        for b in budgets:
            limit = float(b.amount_limit)
            spent = float(b.spent_amount)
            remaining = max(limit - spent, 0)
            utilization = round(spent / limit * 100, 1) if limit > 0 else 0

            # Remaining days
            remaining_days = max((b.end_date - today).days, 0) if b.end_date else 0
            total_days = max((b.end_date - b.start_date).days, 1) if b.end_date and b.start_date else 1
            elapsed_days = total_days - remaining_days

            # Daily rate
            daily_rate = spent / max(elapsed_days, 1)
            projected_total = daily_rate * total_days
            is_on_track = projected_total <= limit

            # Warning level
            if utilization >= 100:
                status = "exceeded"
            elif utilization >= 80:
                status = "warning"
            elif utilization >= 60:
                status = "caution"
            else:
                status = "healthy"

            results.append({
                "id": str(b.id),
                "category": b.category,
                "period": b.period,
                "amount_limit": limit,
                "spent_amount": spent,
                "remaining": remaining,
                "utilization_percent": utilization,
                "remaining_days": remaining_days,
                "daily_rate": round(daily_rate, 2),
                "projected_total": round(projected_total, 2),
                "is_on_track": is_on_track,
                "status": status,
            })

        return results

    async def _sync_spent_amounts(self, user_id: uuid.UUID, budgets: list[Budget]) -> None:
        """Sync spent_amount from actual transactions within budget period."""
        for b in budgets:
            result = await self.db.execute(
                select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                    Transaction.user_id == user_id,
                    Transaction.transaction_type == "expense",
                    Transaction.category == b.category,
                    Transaction.transaction_date >= datetime.combine(
                        b.start_date, datetime.min.time(), tzinfo=timezone.utc
                    ),
                    Transaction.transaction_date <= datetime.combine(
                        b.end_date, datetime.max.time(), tzinfo=timezone.utc
                    ) if b.end_date else True,
                )
            )
            spent = result.scalar() or Decimal("0")
            b.spent_amount = spent
        await self.db.flush()
