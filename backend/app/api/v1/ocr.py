"""FINTELIA — OCR & Parser Router (Phase 3)

Receipt scanning, natural language parsing, and voice
transcript processing endpoints.
"""
from __future__ import annotations

import uuid
from pydantic import BaseModel

from fastapi import APIRouter, Depends, File, Form, UploadFile, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.session import get_db
from app.api.dependencies import get_current_user_id
from app.services.ocr_service import get_ocr_service
from app.services.transaction_parser import get_parser

router = APIRouter(prefix="/ocr", tags=["OCR & Parser"])


class ParseTextRequest(BaseModel):
    text: str
    source: str = "text"  # text | voice


@router.post("/scan-receipt")
async def scan_receipt(
    file: UploadFile = File(...),
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Scan a receipt image and return extracted data."""
    allowed = {"image/jpeg", "image/jpg", "image/png", "image/webp"}
    if file.content_type not in allowed:
        raise HTTPException(400, f"Unsupported file type: {file.content_type}")

    image_bytes = await file.read()
    if len(image_bytes) > 10 * 1024 * 1024:  # 10 MB limit
        raise HTTPException(400, "Image too large. Maximum 10 MB.")

    service = get_ocr_service()
    return await service.scan_receipt(image_bytes, file.content_type)


@router.post("/extract-transaction")
async def extract_transaction(
    file: UploadFile = File(...),
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Scan receipt and return a ready-to-save transaction draft."""
    allowed = {"image/jpeg", "image/jpg", "image/png", "image/webp"}
    if file.content_type not in allowed:
        raise HTTPException(400, f"Unsupported file type: {file.content_type}")

    image_bytes = await file.read()
    service = get_ocr_service()
    return await service.extract_transaction_draft(image_bytes, file.content_type)


@router.post("/parse-text")
async def parse_text(
    data: ParseTextRequest,
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Parse natural language or voice transcript into a transaction draft."""
    if not data.text.strip():
        raise HTTPException(400, "Text cannot be empty")
    parser = get_parser()
    return await parser.parse(data.text)
