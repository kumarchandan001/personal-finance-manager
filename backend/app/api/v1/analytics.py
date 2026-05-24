"""FINTELIA — Analytics Router

Real analytics endpoints powered by SQL aggregation.
"""
import uuid

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.session import get_db
from app.api.dependencies import get_current_user_id
from app.services.analytics_service import AnalyticsService
from app.services.insights_service import InsightsService

router = APIRouter(prefix="/analytics", tags=["Analytics"])


@router.get("/overview")
async def get_overview(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
    days: int = Query(30, ge=1, le=365),
):
    """Financial overview for the last N days."""
    return await AnalyticsService(db).get_overview(user_id, days)


@router.get("/monthly")
async def get_monthly(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
    months: int = Query(6, ge=1, le=24),
):
    """Monthly income/expense breakdown."""
    return await AnalyticsService(db).get_monthly(user_id, months)


@router.get("/weekly")
async def get_weekly(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
    weeks: int = Query(8, ge=1, le=52),
):
    """Weekly income/expense breakdown."""
    return await AnalyticsService(db).get_weekly(user_id, weeks)


@router.get("/categories")
async def get_categories(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
    days: int = Query(30, ge=1, le=365),
):
    """Category-wise spending breakdown."""
    return await AnalyticsService(db).get_categories(user_id, days)


@router.get("/trends")
async def get_trends(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
    months: int = Query(6, ge=1, le=24),
):
    """Spending/income trends with % change."""
    return await AnalyticsService(db).get_trends(user_id, months)


@router.get("/cashflow")
async def get_cashflow(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
    days: int = Query(30, ge=1, le=90),
):
    """Daily cash flow analysis."""
    return await AnalyticsService(db).get_cashflow(user_id, days)


@router.get("/insights")
async def get_insights(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Rule-based financial insights and alerts."""
    return await InsightsService(db).generate_insights(user_id)
