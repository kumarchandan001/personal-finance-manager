import uuid
from datetime import date, datetime, timedelta, timezone
from typing import Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.behavioral import BehavioralAnalytics
from app.models.transaction import Transaction
from app.schemas.behavioral import BehavioralAnalyticsCreate
from app.services.gemini_client import get_gemini_client


class BehavioralService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_summary(self, user_id: uuid.UUID) -> Optional[BehavioralAnalytics]:
        """Get the latest behavioral analytics summary for the user."""
        result = await self.db.execute(
            select(BehavioralAnalytics)
            .where(BehavioralAnalytics.user_id == user_id)
            .order_by(BehavioralAnalytics.created_at.desc())
            .limit(1)
        )
        return result.scalar_one_or_none()

    async def analyze(self, user_id: uuid.UUID) -> BehavioralAnalytics:
        """Trigger a new behavioral analysis based on recent transactions."""
        period_end = date.today()
        period_start = period_end - timedelta(days=30)
        
        dt_end = datetime.now(timezone.utc)
        dt_start = dt_end - timedelta(days=30)

        # Fetch recent transactions
        result = await self.db.execute(
            select(Transaction)
            .where(
                Transaction.user_id == user_id,
                Transaction.transaction_date >= dt_start,
                Transaction.transaction_date <= dt_end,
            )
            .order_by(Transaction.transaction_date.desc())
        )
        transactions = list(result.scalars().all())

        gemini = get_gemini_client()
        
        # Prepare context for AI
        tx_data = []
        for t in transactions:
            tx_data.append(
                f"- {t.transaction_date.date()}: {t.transaction_type} of {t.amount} INR for {t.category} ({t.description or t.merchant or 'No details'})"
            )
        
        tx_context = "\n".join(tx_data) if tx_data else "No transactions in this period."

        prompt = f"""
        Analyze the following recent transactions for the user from {period_start} to {period_end}:
        {tx_context}
        
        Generate a JSON response with the following keys exactly:
        - "emotional_spending_score" (float 0-100, higher means more emotional/impulse spending)
        - "impulse_score" (float 0-100, higher means more impulse buying)
        - "financial_health_score" (float 0-100, overall health based on this period)
        - "behavioral_archetype" (a JSON object with keys "name" and "description". e.g. "Analyzer", "Spender", etc.)
        - "spending_pattern" (a JSON object summarizing top categories and patterns)
        - "recommendations" (a JSON object with keys like 'short_term', 'long_term' containing lists of actionable advice)
        """

        ai_data = await gemini.generate_json(prompt)

        analysis = BehavioralAnalytics(
            user_id=user_id,
            analysis_type="monthly",
            period_start=period_start,
            period_end=period_end,
            spending_pattern=ai_data.get("spending_pattern", {}),
            emotional_spending_score=ai_data.get("emotional_spending_score", 50.0),
            impulse_score=ai_data.get("impulse_score", 50.0),
            financial_health_score=ai_data.get("financial_health_score", 50.0),
            behavioral_archetype=ai_data.get("behavioral_archetype", {"name": "Analyzer", "description": "Needs more data"}),
            recommendations=ai_data.get("recommendations", {"tips": ["Track your spending consistently."]}),
        )

        self.db.add(analysis)
        await self.db.flush()
        
        return analysis
