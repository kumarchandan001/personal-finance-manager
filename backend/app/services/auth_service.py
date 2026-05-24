"""FINTELIA — Auth Service"""
import uuid
from datetime import timedelta

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    hash_password,
    verify_password,
    verify_firebase_token,
    verify_token,
)
from app.core.exceptions import UnauthorizedException, ConflictException, NotFoundException
from app.models.user import User
from app.schemas.auth import TokenResponse


class AuthService:
    """Authentication business logic."""

    def __init__(self, db: AsyncSession):
        self.db = db

    def _create_token_pair(self, user: User) -> TokenResponse:
        """Create access + refresh token pair for a user."""
        token_data = {"sub": str(user.id), "email": user.email}
        access_token = create_access_token(
            data=token_data,
            expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES),
        )
        refresh_token = create_refresh_token(
            data=token_data,
            expires_delta=timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
        )
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def register(self, email: str, password: str, full_name: str, risk_tolerance: str = "moderate") -> TokenResponse:
        """Register a new user and return tokens (auto-login)."""
        existing = await self.db.execute(select(User).where(User.email == email))
        if existing.scalar_one_or_none():
            raise ConflictException("Email already registered")
        user = User(
            email=email,
            full_name=full_name,
            hashed_password=hash_password(password),
            risk_tolerance=risk_tolerance,
        )
        self.db.add(user)
        await self.db.flush()
        return self._create_token_pair(user)

    async def login(self, email: str, password: str) -> TokenResponse:
        """Login with email/password, return tokens."""
        result = await self.db.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()
        if not user or not user.hashed_password:
            raise UnauthorizedException("Invalid email or password")
        if not verify_password(password, user.hashed_password):
            raise UnauthorizedException("Invalid email or password")
        if not user.is_active:
            raise UnauthorizedException("Account is deactivated")
        return self._create_token_pair(user)

    async def login_firebase(self, firebase_token: str) -> TokenResponse:
        """Login/register with Firebase token, return tokens."""
        firebase_data = await verify_firebase_token(firebase_token)
        uid = firebase_data.get("uid", "")
        email = firebase_data.get("email", "")
        name = firebase_data.get("name", "User")

        result = await self.db.execute(select(User).where(User.firebase_uid == uid))
        user = result.scalar_one_or_none()

        if not user:
            # Check if email already exists (link accounts)
            result2 = await self.db.execute(select(User).where(User.email == email))
            user = result2.scalar_one_or_none()
            if user:
                user.firebase_uid = uid
            else:
                user = User(firebase_uid=uid, email=email, full_name=name)
                self.db.add(user)
            await self.db.flush()

        return self._create_token_pair(user)

    async def refresh(self, refresh_token_str: str) -> TokenResponse:
        """Verify a refresh token and issue a new access + refresh pair."""
        payload = verify_token(refresh_token_str, expected_type="refresh")
        if not payload or "sub" not in payload:
            raise UnauthorizedException("Invalid or expired refresh token")

        user_id = uuid.UUID(payload["sub"])
        user = await self.get_user_by_id(user_id)
        if not user.is_active:
            raise UnauthorizedException("Account is deactivated")
        return self._create_token_pair(user)

    async def get_user_by_id(self, user_id: uuid.UUID) -> User:
        """Get a user by ID."""
        result = await self.db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise NotFoundException("User not found")
        return user
