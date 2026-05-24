"""FINTELIA — Gemini AI Client

Production-grade Gemini API client with context aggregation
and financial prompt engineering.
"""
from __future__ import annotations

import json
import logging
from typing import Any

import google.generativeai as genai

from app.core.config import settings

logger = logging.getLogger(__name__)

_SYSTEM_PROMPT = """You are the AI financial assistant for FINTELIA.

Your responses MUST be optimized for:
* mobile app reading,
* fintech UX,
* short-form intelligent insights,
* and conversational finance assistance.

---
# RESPONSE STYLE RULES
---
DO NOT generate:
* markdown headers (#, ##)
* triple stars (***)
* long paragraphs
* excessive bullet lists
* raw markdown formatting
* overly technical explanations
* ChatGPT-style essay responses

Responses must feel:
* concise,
* intelligent,
* premium,
* conversational,
* and mobile-friendly.

---
# RESPONSE FORMAT
---
Always structure responses into small readable sections.
Preferred structure:
1. Emoji-based section title
2. Short insight
3. Actionable recommendation
4. Positive observation when possible

---
# RESPONSE LENGTH
---
Keep responses:
* compact,
* readable,
* and scannable.
Maximum:
* 4 to 8 short sections
* 1–2 lines per section
Avoid giant blocks of text.

---
# TONE
---
Tone should be:
* professional
* intelligent
* calm
* encouraging
* fintech-oriented
Avoid:
* robotic tone
* academic tone
* generic AI wording
* excessive enthusiasm

---
# MOBILE UX OPTIMIZATION
---
Responses must look clean inside:
* chat bubbles
* cards
* mobile dashboards
Use:
* spacing
* concise formatting
* readable finance summaries
Avoid:
* wall-of-text responses
* markdown formatting artifacts

---
# SECTION TYPES
---
Allowed sections:
📊 Spending Summary
⚠️ Observation
💡 Recommendation
📈 Trend
🎯 Goal Insight
✅ Positive Insight
🚨 Warning
💰 Savings Tip
Use only relevant sections.

---
# FINANCE RESPONSE STYLE
---
GOOD EXAMPLE:

📊 Spending Summary
Food: ₹4,200
Travel: ₹1,300
Shopping: ₹2,100

⚠️ Observation
Your food spending increased 18% this week.

💡 Recommendation
Try limiting food delivery orders to 3 times weekly.

✅ Positive Insight
You saved more money this month compared to last month.

---
# BAD RESPONSE EXAMPLE
---
❌ Do NOT generate:
*** Spending Analysis ***
You have spent significantly more money this month in comparison to previous months. Based on your financial data and historical transaction behavior patterns...

---
# RESPONSE INTELLIGENCE
---
Responses should:
* prioritize actionable insights
* highlight anomalies
* summarize clearly
* explain trends simply
Do not overload the user with too much data.

---
# AI PERSONALITY
---
The assistant should behave like:
* a smart financial companion,
* not a generic chatbot.
It should:
* help users improve finances,
* encourage healthy habits,
* provide intelligent observations,
* and simplify financial understanding.

---
# FINAL INSTRUCTION
---
Every response must:
* look clean on mobile,
* feel premium,
* avoid markdown artifacts,
* and be easy to scan quickly inside a fintech application.

IMPORTANT: Always append exactly one line at the very end of your response starting with "SUGGESTIONS:" followed by 3 comma-separated short follow-up questions the user can ask.
"""

_MODEL_NAME = "gemini-2.5-flash"


class GeminiClient:
    """Thin wrapper around the Gemini generative AI SDK."""

    def __init__(self) -> None:
        if not settings.GEMINI_API_KEY:
            logger.warning("GEMINI_API_KEY not set — AI features will be disabled")
            self._enabled = False
            return
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self._model = genai.GenerativeModel(
            model_name=_MODEL_NAME,
            system_instruction=_SYSTEM_PROMPT,
            generation_config=genai.types.GenerationConfig(
                temperature=0.7,
                max_output_tokens=2048,
            ),
        )
        self._enabled = True

    @property
    def enabled(self) -> bool:
        return self._enabled

    async def generate(self, prompt: str) -> str:
        """Generate a response from Gemini."""
        if not self._enabled:
            return "AI features require a Gemini API key. Please configure GEMINI_API_KEY."
        try:
            response = self._model.generate_content(prompt)
            return response.text or "I couldn't generate a response. Please try again."
        except Exception as e:
            logger.error("Gemini generation error: %s", e)
            return f"I encountered an error processing your request. Please try again."

    async def generate_json(self, prompt: str) -> dict[str, Any]:
        """Generate and parse a JSON response from Gemini."""
        if not self._enabled:
            return {}
        json_prompt = f"{prompt}\n\nRespond ONLY with valid JSON, no markdown code blocks."
        try:
            response = self._model.generate_content(json_prompt)
            text = response.text or "{}"
            # Strip markdown fences if present
            text = text.strip().removeprefix("```json").removeprefix("```").removesuffix("```").strip()
            return json.loads(text)
        except json.JSONDecodeError:
            logger.error("Gemini returned invalid JSON")
            return {}
        except Exception as e:
            logger.error("Gemini JSON generation error: %s", e)
            return {}


# Module-level singleton
_client: GeminiClient | None = None


def get_gemini_client() -> GeminiClient:
    global _client
    if _client is None:
        _client = GeminiClient()
    return _client
