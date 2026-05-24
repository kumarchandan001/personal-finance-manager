"""FINTELIA — API Dependencies"""
import uuid
from fastapi import Header
from app.core.security import verify_token
from app.core.exceptions import UnauthorizedException


async def get_current_user_id(
    authorization: str = Header(..., description="Bearer token"),
) -> uuid.UUID:
    """Extract and verify user ID from JWT access token."""
    if not authorization.startswith("Bearer "):
        raise UnauthorizedException("Invalid authorization header")
    token = authorization.replace("Bearer ", "")
    payload = verify_token(token, expected_type="access")
    if not payload or "sub" not in payload:
        raise UnauthorizedException("Invalid or expired token")
    return uuid.UUID(payload["sub"])
