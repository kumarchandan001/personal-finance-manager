"""FINTELIA — Auth Router"""
import uuid

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database.session import get_db
from app.api.dependencies import get_current_user_id
from app.services.auth_service import AuthService
from app.schemas.user import UserCreate, UserResponse
from app.schemas.auth import LoginRequest, TokenResponse, FirebaseLoginRequest, RefreshTokenRequest

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse, status_code=201)
async def register(data: UserCreate, db: AsyncSession = Depends(get_db)):
    """Register a new user account. Returns tokens for auto-login."""
    service = AuthService(db)
    return await service.register(
        email=data.email,
        password=data.password,
        full_name=data.full_name,
        risk_tolerance=data.risk_tolerance,
    )


@router.post("/login", response_model=TokenResponse)
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Login with email and password."""
    service = AuthService(db)
    return await service.login(data.email, data.password)


@router.post("/login/firebase", response_model=TokenResponse)
async def login_firebase(data: FirebaseLoginRequest, db: AsyncSession = Depends(get_db)):
    """Login or register with Firebase ID token."""
    service = AuthService(db)
    return await service.login_firebase(data.firebase_token)


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(data: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    """Refresh an expired access token using a valid refresh token."""
    service = AuthService(db)
    return await service.refresh(data.refresh_token)


@router.get("/me", response_model=UserResponse)
async def get_me(
    user_id: uuid.UUID = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Get the currently authenticated user's profile."""
    service = AuthService(db)
    return await service.get_user_by_id(user_id)
