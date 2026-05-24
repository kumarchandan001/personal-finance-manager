"""FINTELIA — AI Assistant Service

Orchestrates Gemini API calls with financial context injection,
spending analysis, recommendations, and smart summarization.
"""
from __future__ import annotations

import uuid

from sqlalchemy.ext.asyncio import AsyncSession

from app.services.gemini_client import get_gemini_client
from app.services.financial_context import FinancialContextBuilder


_SUGGESTION_DEFAULTS = [
    "How can I save more money?",
    "Which category am I overspending on?",
    "Give me a budget plan",
    "Summarize my spending this month",
    "What are my top expenses?",
]


def _parse_suggestions(text: str) -> tuple[str, list[str]]:
    """Extract SUGGESTIONS: line from AI response and return clean text + chips."""
    if "SUGGESTIONS:" in text:
        parts = text.rsplit("SUGGESTIONS:", 1)
        clean = parts[0].strip()
        raw = parts[1].strip()
        chips = [s.strip() for s in raw.split(",") if s.strip()][:4]
        return clean, chips
    return text.strip(), []


class AIAssistantService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self._client = get_gemini_client()
        self._ctx_builder = FinancialContextBuilder(db)

    async def chat(self, user_id: uuid.UUID, message: str) -> dict:
        """Handle a conversational finance query."""
        context = await self._ctx_builder.build(user_id)
        prompt = f"""{context}

USER QUESTION: {message}

Answer the user's financial question based on their data above.
Be specific with their numbers. End with: SUGGESTIONS: chip1, chip2, chip3"""

        raw = await self._client.generate(prompt)
        response, chips = _parse_suggestions(raw)
        return {
            "response": response,
            "suggestions": chips or _SUGGESTION_DEFAULTS[:3],
        }

    async def analyze_spending(self, user_id: uuid.UUID) -> dict:
        """Deep spending analysis with actionable recommendations."""
        context = await self._ctx_builder.build(user_id, days=30)
        prompt = f"""{context}

Analyze this user's spending patterns in detail. Identify:
1. Top problem areas
2. Quick wins to save money
3. Budget adjustments recommended
4. Overall financial health assessment (score 1-10 with reason)

Be specific using their actual numbers. Keep each point to 1-2 sentences.
End with: SUGGESTIONS: tip1, tip2, tip3"""

        raw = await self._client.generate(prompt)
        response, chips = _parse_suggestions(raw)
        return {
            "analysis": response,
            "suggestions": chips or ["View Budget Details", "Check Analytics", "Set a Savings Goal"],
        }

    async def get_summary(self, user_id: uuid.UUID) -> dict:
        """Generate a concise monthly financial narrative."""
        context = await self._ctx_builder.build(user_id, days=30)
        prompt = f"""{context}

Write a brief, encouraging monthly financial summary (3-4 sentences) for this user.
Include their net savings, biggest expense category, and one specific improvement tip.
Make it personal and motivating.
End with: SUGGESTIONS: action1, action2"""

        raw = await self._client.generate(prompt)
        response, chips = _parse_suggestions(raw)
        return {
            "summary": response,
            "suggestions": chips or ["View Full Analytics", "Check Budget Progress"],
        }

    async def get_recommendations(self, user_id: uuid.UUID) -> list[dict]:
        """Generate structured financial recommendations."""
        context = await self._ctx_builder.build(user_id, days=30)
        prompt = f"""{context}

Generate 4 specific, actionable financial recommendations for this user based on their data.
Return as JSON array with objects: {{
  "title": "short title",
  "description": "1-2 sentence actionable advice",
  "type": "savings|budget|goal|spending",
  "priority": "high|medium|low",
  "potential_saving": <number or null>
}}"""

        data = await self._client.generate_json(prompt)
        if isinstance(data, list):
            return data
        return []

    async def categorize_transaction(self, description: str, merchant: str = "", amount: float = 0) -> dict:
        """AI-powered transaction categorization."""
        prompt = f"""Categorize this transaction and return JSON:
Description: "{description}"
Merchant: "{merchant}"
Amount: ?{amount}

Return JSON: {{"category": "...", "subcategory": "...", "transaction_type": "income|expense", "confidence": 0.0-1.0}}
Categories: Food, Transport, Shopping, Entertainment, Bills, Health, Travel, Education, Salary, Investment, Other"""

        data = await self._client.generate_json(prompt)
        return data or {
            "category": "Other",
            "subcategory": None,
            "transaction_type": "expense",
            "confidence": 0.5,
        }
