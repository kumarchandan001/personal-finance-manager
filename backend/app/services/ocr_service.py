"""FINTELIA — OCR Receipt Scanner

Uses Gemini Vision to extract structured transaction data
from receipt images (base64-encoded). No external OCR dependency needed.
"""
from __future__ import annotations

import base64
import logging
from typing import Any

import google.generativeai as genai

from app.core.config import settings

logger = logging.getLogger(__name__)

_OCR_PROMPT = """You are a receipt OCR specialist. Analyze this receipt image and extract transaction data.

Return ONLY valid JSON with this exact structure:
{
  "merchant": "store or business name",
  "amount": <total amount as number>,
  "currency": "INR",
  "date": "YYYY-MM-DD or null if unclear",
  "category": "Food|Transport|Shopping|Entertainment|Bills|Health|Travel|Other",
  "items": [{"name": "item", "price": 0.00}],
  "payment_method": "cash|card|digital|unknown",
  "tax": <tax amount or null>,
  "confidence": <0.0-1.0>,
  "notes": "any additional relevant info"
}

If a field cannot be determined, use null. Always include merchant and amount."""


class OCRService:
    """Vision-based receipt scanner using Gemini multimodal."""

    def __init__(self) -> None:
        if not settings.GEMINI_API_KEY:
            self._enabled = False
            return
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self._model = genai.GenerativeModel("gemini-1.5-flash")
        self._enabled = True

    @property
    def enabled(self) -> bool:
        return self._enabled

    async def scan_receipt(self, image_bytes: bytes, mime_type: str = "image/jpeg") -> dict[str, Any]:
        """Extract structured transaction from receipt image bytes."""
        if not self._enabled:
            return {"error": "OCR requires GEMINI_API_KEY", "confidence": 0}

        try:
            image_part = {
                "mime_type": mime_type,
                "data": base64.b64encode(image_bytes).decode("utf-8"),
            }

            response = self._model.generate_content(
                [_OCR_PROMPT, image_part],
                generation_config=genai.types.GenerationConfig(temperature=0.1),
            )

            text = response.text or "{}"
            text = text.strip().removeprefix("```json").removeprefix("```").removesuffix("```").strip()

            import json
            result = json.loads(text)
            return result

        except Exception as e:
            logger.error("OCR scan error: %s", e)
            return {"error": str(e), "confidence": 0}

    async def extract_transaction_draft(self, image_bytes: bytes, mime_type: str = "image/jpeg") -> dict[str, Any]:
        """Scan receipt and return a ready-to-create transaction draft."""
        extracted = await self.scan_receipt(image_bytes, mime_type)

        # Map to transaction schema
        return {
            "amount": extracted.get("amount"),
            "merchant": extracted.get("merchant"),
            "category": extracted.get("category", "Other"),
            "description": extracted.get("merchant"),
            "transaction_type": "expense",
            "payment_method": extracted.get("payment_method", "unknown"),
            "date": extracted.get("date"),
            "currency": extracted.get("currency", "INR"),
            "notes": extracted.get("notes"),
            "confidence": extracted.get("confidence", 0),
            "raw": extracted,
        }


_ocr_service: OCRService | None = None


def get_ocr_service() -> OCRService:
    global _ocr_service
    if _ocr_service is None:
        _ocr_service = OCRService()
    return _ocr_service
