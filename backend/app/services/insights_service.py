"""FINTELIA — Financial Insights Engine

Rule-based intelligence generating actionable financial insights
from transaction and budget data. Foundation for future AI phases.
"""
import uuid
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.transaction import Transaction
from app.models.budget import Budget


class InsightsService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def generate_insights(self, user_id: uuid.UUID) -> list[dict]:
        """Generate all rule-based insights for a user."""
        insights: list[dict] = []

        insights.extend(await self._spending_change_insights(user_id))
        insights.extend(await self._budget_alerts(user_id))
        insights.extend(await self._top_expense_insights(user_id))
        insights.extend(await self._savings_insights(user_id))

        return insights

    async def _spending_change_insights(self, user_id: uuid.UUID) -> list[dict]:
        """Detect week-over-week spending changes per category."""
        now = datetime.now(timezone.utc)
        this_week_start = now - timedelta(days=7)
        prev_week_start = now - timedelta(days=14)

        this_week = await self._category_totals(user_id, this_week_start, now)
        prev_week = await self._category_totals(user_id, prev_week_start, this_week_start)

        insights = []
        for cat, amount in this_week.items():
            prev_amount = prev_week.get(cat, 0)
            if prev_amount > 0:
                pct_change = ((amount - prev_amount) / prev_amount) * 100
                if pct_change > 15:
                    insights.append({
                        "type": "overspending",
                        "title": f"{cat} spending up",
                        "message": f"You spent {pct_change:.0f}% more on {cat} this week (?{amount:.0f} vs ?{prev_amount:.0f}).",
                        "severity": "warning",
                        "category": cat,
                        "value": round(pct_change, 1),
                    })
                elif pct_change < -15:
                    insights.append({
                        "type": "saving",
                        "title": f"Great savings on {cat}!",
                        "message": f"You reduced {cat} spending by {abs(pct_change):.0f}% this week.",
                        "severity": "success",
                        "category": cat,
                        "value": round(abs(pct_change), 1),
                    })
        return insights

    async def _budget_alerts(self, user_id: uuid.UUID) -> list[dict]:
        """Check budgets for overspending or near-limit."""
        result = await self.db.execute(
            select(Budget).where(Budget.user_id == user_id, Budget.is_active.is_(True))
        )
        budgets = result.scalars().all()

        insights = []
        for b in budgets:
            if b.amount_limit <= 0:
                continue
            ratio = float(b.spent_amount) / float(b.amount_limit)
            if ratio >= 1.0:
                insights.append({
                    "type": "alert",
                    "title": f"{b.category} budget exceeded!",
                    "message": f"You've spent ?{float(b.spent_amount):.0f} of your ?{float(b.amount_limit):.0f} {b.category} budget ({ratio*100:.0f}%).",
                    "severity": "danger",
                    "category": b.category,
                    "value": round(ratio * 100, 1),
                })
            elif ratio >= 0.8:
                insights.append({
                    "type": "alert",
                    "title": f"{b.category} budget nearly full",
                    "message": f"You've used {ratio*100:.0f}% of your {b.category} budget. ?{float(b.amount_limit - b.spent_amount):.0f} remaining.",
                    "severity": "warning",
                    "category": b.category,
                    "value": round(ratio * 100, 1),
                })
        return insights

    async def _top_expense_insights(self, user_id: uuid.UUID) -> list[dict]:
        """Identify top spending category."""
        now = datetime.now(timezone.utc)
        since = now - timedelta(days=30)

        result = await self.db.execute(
            select(Transaction.category, func.sum(Transaction.amount).label("total"))
            .where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "expense",
                Transaction.transaction_date >= since,
            )
            .group_by(Transaction.category)
            .order_by(func.sum(Transaction.amount).desc())
            .limit(1)
        )
        row = result.first()
        if row:
            return [{
                "type": "tip",
                "title": f"Top expense: {row.category}",
                "message": f"Your biggest spending category this month is {row.category} at ?{float(row.total):.0f}.",
                "severity": "info",
                "category": row.category,
                "value": float(row.total),
            }]
        return []

    async def _savings_insights(self, user_id: uuid.UUID) -> list[dict]:
        """Month-over-month savings comparison."""
        now = datetime.now(timezone.utc)
        this_month_start = now.replace(day=1, hour=0, minute=0, second=0)
        prev_month_start = (this_month_start - timedelta(days=1)).replace(day=1)

        this_income = await self._sum_type(user_id, "income", this_month_start, now)
        this_expense = await self._sum_type(user_id, "expense", this_month_start, now)
        prev_income = await self._sum_type(user_id, "income", prev_month_start, this_month_start)
        prev_expense = await self._sum_type(user_id, "expense", prev_month_start, this_month_start)

        this_savings = this_income - this_expense
        prev_savings = prev_income - prev_expense

        insights = []
        if prev_savings > 0 and this_savings > prev_savings:
            pct = ((this_savings - prev_savings) / prev_savings) * 100
            insights.append({
                "type": "saving",
                "title": "Savings improving!",
                "message": f"You're saving {pct:.0f}% more this month compared to last month.",
                "severity": "success",
                "value": round(pct, 1),
            })
        elif this_savings < 0:
            insights.append({
                "type": "alert",
                "title": "Spending exceeds income",
                "message": f"You're spending ?{abs(this_savings):.0f} more than you earn this month.",
                "severity": "danger",
                "value": round(abs(this_savings), 2),
            })
        return insights

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    async def _category_totals(self, user_id: uuid.UUID, start: datetime, end: datetime) -> dict[str, float]:
        result = await self.db.execute(
            select(Transaction.category, func.sum(Transaction.amount).label("total"))
            .where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "expense",
                Transaction.transaction_date >= start,
                Transaction.transaction_date < end,
            )
            .group_by(Transaction.category)
        )
        return {r.category: float(r.total or 0) for r in result.all()}

    async def _sum_type(self, user_id: uuid.UUID, txn_type: str, start: datetime, end: datetime) -> float:
        result = await self.db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == txn_type,
                Transaction.transaction_date >= start,
                Transaction.transaction_date < end,
            )
        )
        return float(result.scalar() or 0)
