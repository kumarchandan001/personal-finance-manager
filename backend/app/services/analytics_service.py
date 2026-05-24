"""FINTELIA — Analytics Service

SQL-powered financial analytics engine with aggregations for
overview, monthly, weekly, category, trends, and cashflow analysis.
"""
import uuid
from datetime import datetime, timedelta, timezone, date
from decimal import Decimal

from sqlalchemy import select, func, extract, cast, Date
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.transaction import Transaction


class AnalyticsService:
    def __init__(self, db: AsyncSession):
        self.db = db

    # ------------------------------------------------------------------
    # Overview
    # ------------------------------------------------------------------
    async def get_overview(self, user_id: uuid.UUID, days: int = 30) -> dict:
        """Financial overview for the last N days."""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        income = await self._sum_by_type(user_id, "income", since)
        expense = await self._sum_by_type(user_id, "expense", since)
        count = await self._count(user_id, since)

        net = income - expense
        avg_daily = expense / max(days, 1)
        savings_rate = (net / income * 100) if income > 0 else 0

        return {
            "total_income": income,
            "total_expense": expense,
            "net_savings": net,
            "balance": net,
            "transaction_count": count,
            "avg_daily_expense": round(avg_daily, 2),
            "savings_rate": round(savings_rate, 1),
        }

    # ------------------------------------------------------------------
    # Monthly breakdown
    # ------------------------------------------------------------------
    async def get_monthly(self, user_id: uuid.UUID, months: int = 6) -> list[dict]:
        """Monthly income/expense breakdown for the last N months."""
        since = datetime.now(timezone.utc) - timedelta(days=months * 31)

        result = await self.db.execute(
            select(
                func.to_char(Transaction.transaction_date, "YYYY-MM").label("month"),
                Transaction.transaction_type,
                func.sum(Transaction.amount).label("total"),
            )
            .where(Transaction.user_id == user_id, Transaction.transaction_date >= since)
            .group_by("month", Transaction.transaction_type)
            .order_by("month")
        )

        month_map: dict[str, dict] = {}
        for row in result.all():
            m = row.month
            if m not in month_map:
                month_map[m] = {"month": m, "income": 0.0, "expense": 0.0, "net": 0.0}
            val = float(row.total or 0)
            if row.transaction_type == "income":
                month_map[m]["income"] = val
            else:
                month_map[m]["expense"] = val
            month_map[m]["net"] = month_map[m]["income"] - month_map[m]["expense"]

        return list(month_map.values())

    # ------------------------------------------------------------------
    # Weekly breakdown
    # ------------------------------------------------------------------
    async def get_weekly(self, user_id: uuid.UUID, weeks: int = 8) -> list[dict]:
        """Weekly income/expense breakdown for the last N weeks."""
        since = datetime.now(timezone.utc) - timedelta(weeks=weeks)

        result = await self.db.execute(
            select(
                func.date_trunc("week", Transaction.transaction_date).label("week_start"),
                Transaction.transaction_type,
                func.sum(Transaction.amount).label("total"),
            )
            .where(Transaction.user_id == user_id, Transaction.transaction_date >= since)
            .group_by("week_start", Transaction.transaction_type)
            .order_by("week_start")
        )

        week_map: dict[str, dict] = {}
        for row in result.all():
            ws = str(row.week_start.date()) if row.week_start else "unknown"
            if ws not in week_map:
                week_map[ws] = {"week_start": ws, "income": 0.0, "expense": 0.0, "net": 0.0}
            val = float(row.total or 0)
            if row.transaction_type == "income":
                week_map[ws]["income"] = val
            else:
                week_map[ws]["expense"] = val
            week_map[ws]["net"] = week_map[ws]["income"] - week_map[ws]["expense"]

        return list(week_map.values())

    # ------------------------------------------------------------------
    # Category breakdown
    # ------------------------------------------------------------------
    async def get_categories(self, user_id: uuid.UUID, days: int = 30) -> list[dict]:
        """Category-wise spending breakdown."""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        result = await self.db.execute(
            select(
                Transaction.category,
                func.sum(Transaction.amount).label("total"),
                func.count(Transaction.id).label("cnt"),
            )
            .where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == "expense",
                Transaction.transaction_date >= since,
            )
            .group_by(Transaction.category)
            .order_by(func.sum(Transaction.amount).desc())
        )

        rows = result.all()
        grand_total = sum(float(r.total or 0) for r in rows)

        return [
            {
                "category": r.category,
                "amount": float(r.total or 0),
                "count": r.cnt,
                "percentage": round(float(r.total or 0) / grand_total * 100, 1) if grand_total > 0 else 0,
            }
            for r in rows
        ]

    # ------------------------------------------------------------------
    # Trends
    # ------------------------------------------------------------------
    async def get_trends(self, user_id: uuid.UUID, months: int = 6) -> dict:
        """Expense/income trend with % change."""
        monthly = await self.get_monthly(user_id, months)
        if len(monthly) < 2:
            return {"months": monthly, "expense_trend": 0, "income_trend": 0}

        prev = monthly[-2]
        curr = monthly[-1]
        exp_trend = ((curr["expense"] - prev["expense"]) / prev["expense"] * 100) if prev["expense"] > 0 else 0
        inc_trend = ((curr["income"] - prev["income"]) / prev["income"] * 100) if prev["income"] > 0 else 0

        return {
            "months": monthly,
            "expense_trend": round(exp_trend, 1),
            "income_trend": round(inc_trend, 1),
        }

    # ------------------------------------------------------------------
    # Cash flow
    # ------------------------------------------------------------------
    async def get_cashflow(self, user_id: uuid.UUID, days: int = 30) -> list[dict]:
        """Daily cash flow for the last N days."""
        since = datetime.now(timezone.utc) - timedelta(days=days)

        result = await self.db.execute(
            select(
                cast(Transaction.transaction_date, Date).label("day"),
                Transaction.transaction_type,
                func.sum(Transaction.amount).label("total"),
            )
            .where(Transaction.user_id == user_id, Transaction.transaction_date >= since)
            .group_by("day", Transaction.transaction_type)
            .order_by("day")
        )

        day_map: dict[str, dict] = {}
        for row in result.all():
            d = str(row.day)
            if d not in day_map:
                day_map[d] = {"period": d, "inflows": 0.0, "outflows": 0.0, "net_flow": 0.0}
            val = float(row.total or 0)
            if row.transaction_type == "income":
                day_map[d]["inflows"] = val
            else:
                day_map[d]["outflows"] = val
            day_map[d]["net_flow"] = day_map[d]["inflows"] - day_map[d]["outflows"]

        return list(day_map.values())

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    async def _sum_by_type(self, user_id: uuid.UUID, txn_type: str, since: datetime) -> float:
        result = await self.db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.transaction_type == txn_type,
                Transaction.transaction_date >= since,
            )
        )
        return float(result.scalar() or 0)

    async def _count(self, user_id: uuid.UUID, since: datetime) -> int:
        result = await self.db.execute(
            select(func.count(Transaction.id)).where(
                Transaction.user_id == user_id,
                Transaction.transaction_date >= since,
            )
        )
        return result.scalar() or 0
