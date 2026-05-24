"""FINTELIA — Financial Context Builder

Aggregates user's financial data into a structured context
for Gemini prompt injection. Keeps prompts factual and grounded.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.transaction import Transaction
from app.models.budget import Budget
from app.models.goal import Goal


class FinancialContextBuilder:
    """Builds a compact financial summary for AI prompt injection."""

    def __init__(self, db: AsyncSession):
        self.db = db

    async def build(self, user_id: uuid.UUID, days: int = 30) -> str:
        """Return a formatted financial context string."""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        # Income / expense totals
        inc_row = await self.db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "income",
                Transaction.transaction_date >= since,
            )
        )
        income = float(inc_row.scalar() or 0)

        exp_row = await self.db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "expense",
                Transaction.transaction_date >= since,
            )
        )
        expense = float(exp_row.scalar() or 0)

        # Top 5 categories
        cat_result = await self.db.execute(
            select(Transaction.category, func.sum(Transaction.amount).label("total"))
            .where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "expense",
                Transaction.transaction_date >= since,
            )
            .group_by(Transaction.category)
            .order_by(func.sum(Transaction.amount).desc())
            .limit(5)
        )
        categories = [(r.category, float(r.total or 0)) for r in cat_result.all()]

        # Active budgets
        budget_result = await self.db.execute(
            select(Budget).where(Budget.user_id == user_id, Budget.is_active.is_(True))
        )
        budgets = budget_result.scalars().all()

        # Active goals
        goal_result = await self.db.execute(
            select(Goal).where(Goal.user_id == user_id, Goal.status == "active")
        )
        goals = goal_result.scalars().all()

        # Recent 5 transactions
        recent_result = await self.db.execute(
            select(Transaction)
            .where(Transaction.user_id == user_id)
            .order_by(Transaction.transaction_date.desc())
            .limit(5)
        )
        recent = recent_result.scalars().all()

        # Build context string
        ctx = f"""=== USER FINANCIAL CONTEXT (last {days} days) ===
Income: ?{income:.2f}
Expenses: ?{expense:.2f}
Net Savings: ?{income - expense:.2f}
Savings Rate: {((income - expense) / income * 100) if income > 0 else 0:.1f}%

Top Spending Categories:
{chr(10).join(f"  - {cat}: ?{amt:.2f}" for cat, amt in categories) or "  No expense data"}

Active Budgets:
{chr(10).join(f"  - {b.category}: ?{float(b.spent_amount):.2f} / ?{float(b.amount_limit):.2f} ({float(b.spent_amount)/float(b.amount_limit)*100:.0f}%)" for b in budgets) or "  No active budgets"}

Financial Goals:
{chr(10).join(f"  - {g.title}: ?{float(g.current_amount):.2f} / ?{float(g.target_amount):.2f}" for g in goals) or "  No active goals"}

Recent Transactions:
{chr(10).join(f"  - {t.transaction_type.upper()} ?{float(t.amount):.2f} [{t.category}] {t.description or ''}" for t in recent) or "  No recent transactions"}
=== END CONTEXT ==="""

        return ctx
