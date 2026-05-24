"""FINTELIA — Smart Transaction Parser

Parses natural language text (voice transcripts, user input)
into structured transaction objects using Gemini.
Falls back to regex-based extraction when AI is unavailable.
"""
from __future__ import annotations

import re
from datetime import date
from typing import Any

from app.services.gemini_client import get_gemini_client

_NL_PROMPT = """Parse this natural language expense description into a structured transaction.

Input: "{text}"

Return ONLY valid JSON:
{{
  "amount": <number>,
  "currency": "INR",
  "category": "Food|Transport|Shopping|Entertainment|Bills|Health|Travel|Salary|Other",
  "merchant": "merchant name or null",
  "description": "clean description",
  "transaction_type": "income|expense",
  "date": "today",
  "confidence": <0.0-1.0>
}}

Examples:
- "Spent 45 on groceries" → amount: 45, category: Food, type: expense
- "Got salary 5000" → amount: 5000, category: Salary, type: income
- "Uber 18 INR (?)s" → amount: 18, category: Transport, merchant: Uber, type: expense"""

_AMOUNT_RE = re.compile(r"[\?₹€£]?\s*(\d+(?:[.,]\d{1,2})?)", re.IGNORECASE)
_CATEGORY_KEYWORDS = {
    "food": ["food", "groceries", "grocery", "restaurant", "eat", "lunch", "dinner", "breakfast", "coffee", "cafe"],
    "Transport": ["uber", "lyft", "taxi", "cab", "bus", "metro", "transport", "fuel", "gas", "petrol", "ride"],
    "Shopping": ["shopping", "amazon", "clothes", "shop", "store", "mall", "buy", "purchase"],
    "Bills": ["electricity", "water", "internet", "bill", "utility", "rent", "phone"],
    "Health": ["doctor", "hospital", "medicine", "pharmacy", "health", "gym", "medical"],
    "Entertainment": ["movie", "netflix", "spotify", "game", "entertainment", "concert"],
    "Salary": ["salary", "paycheck", "wage", "income", "received", "got paid"],
}


def _regex_parse(text: str) -> dict[str, Any]:
    """Lightweight regex fallback parser."""
    text_lower = text.lower()

    # Extract amount
    amount_match = _AMOUNT_RE.search(text)
    amount = float(amount_match.group(1).replace(",", ".")) if amount_match else None

    # Detect category
    category = "Other"
    for cat, keywords in _CATEGORY_KEYWORDS.items():
        if any(kw in text_lower for kw in keywords):
            category = cat
            break

    # Detect type
    income_words = ["salary", "received", "got", "income", "earned", "paycheck", "wage"]
    txn_type = "income" if any(w in text_lower for w in income_words) else "expense"

    return {
        "amount": amount,
        "currency": "INR",
        "category": category,
        "merchant": None,
        "description": text.strip(),
        "transaction_type": txn_type,
        "date": date.today().isoformat(),
        "confidence": 0.6 if amount else 0.2,
    }


class TransactionParser:
    """Parses natural language into transaction drafts."""

    def __init__(self) -> None:
        self._client = get_gemini_client()

    async def parse(self, text: str) -> dict[str, Any]:
        """Parse natural language text into a transaction draft."""
        if self._client.enabled:
            result = await self._client.generate_json(_NL_PROMPT.format(text=text))
            if result and result.get("amount"):
                if not result.get("date") or result["date"] == "today":
                    result["date"] = date.today().isoformat()
                return result

        # Fallback to regex
        return _regex_parse(text)


_parser: TransactionParser | None = None


def get_parser() -> TransactionParser:
    global _parser
    if _parser is None:
        _parser = TransactionParser()
    return _parser
