"""FINTELIA — Analytics Schemas"""
from datetime import date
from pydantic import BaseModel


class AnalyticsOverview(BaseModel):
    total_income: float = 0
    total_expense: float = 0
    net_savings: float = 0
    balance: float = 0
    transaction_count: int = 0
    avg_daily_expense: float = 0
    savings_rate: float = 0


class CategoryBreakdown(BaseModel):
    category: str
    amount: float
    count: int
    percentage: float


class MonthlyData(BaseModel):
    month: str  # "2026-01"
    income: float
    expense: float
    net: float


class WeeklyData(BaseModel):
    week_start: str  # ISO date
    income: float
    expense: float
    net: float


class TrendData(BaseModel):
    months: list[MonthlyData]
    expense_trend: float  # % change vs previous period
    income_trend: float


class CashFlowData(BaseModel):
    period: str
    inflows: float
    outflows: float
    net_flow: float


class InsightItem(BaseModel):
    type: str  # overspending, saving, alert, tip
    title: str
    message: str
    severity: str = "info"  # info, warning, success, danger
    category: str | None = None
    value: float | None = None
