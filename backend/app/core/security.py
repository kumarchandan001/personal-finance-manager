"""
FINTELIA — Security Utilities

JWT access/refresh token management, password hashing, Firebase verification.
"""

from datetime import datetime, timedelta, timezone
from typing import Any

from jose import JWTError, jwt
import bcrypt

from app.core.config import settings

# ---------------------------------------------------------------------------
# JWT Tokens
# ---------------------------------------------------------------------------

def create_access_token(
    data: dict[str, Any],
    expires_delta: timedelta | None = None,
) -> str:
    """Create a short-lived JWT access token."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(
    data: dict[str, Any],
    expires_delta: timedelta | None = None,
) -> str:
    """Create a long-lived JWT refresh token."""
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + (
        expires_delta or timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    )
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def verify_token(token: str, expected_type: str = "access") -> dict[str, Any] | None:
    """Verify and decode a JWT token. Returns payload or None."""
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM]
        )
        # Check token type matches expected
        if payload.get("type") != expected_type:
            return None
        return payload
    except JWTError:
        return None


# ---------------------------------------------------------------------------
# Password Hashing
# ---------------------------------------------------------------------------

def hash_password(password: str) -> str:
    """Hash a plaintext password."""
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a plaintext password against its hash."""
    try:
        return bcrypt.checkpw(
            plain_password.encode('utf-8'),
            hashed_password.encode('utf-8')
        )
    except ValueError:
        return False


# ---------------------------------------------------------------------------
# Firebase Token Verification
# ---------------------------------------------------------------------------

# Lazy-init Firebase Admin SDK
_firebase_app_initialized = False


def _ensure_firebase_initialized() -> bool:
    """Initialize Firebase Admin SDK if not already done. Returns True if available."""
    global _firebase_app_initialized
    if _firebase_app_initialized:
        return True
    if not settings.firebase_enabled:
        return False
    try:
        import firebase_admin
        from firebase_admin import credentials

        if not firebase_admin._apps:
            if settings.FIREBASE_CREDENTIALS_PATH:
                cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
                firebase_admin.initialize_app(cred)
            else:
                # Use Application Default Credentials
                firebase_admin.initialize_app()
        _firebase_app_initialized = True
        return True
    except Exception:
        return False


async def verify_firebase_token(token: str) -> dict[str, Any]:
    """
    Verify a Firebase ID token.

    Returns decoded token data with uid, email, and name.
    Falls back to a stub if Firebase Admin SDK is not configured.
    """
    if _ensure_firebase_initialized():
        try:
            from firebase_admin import auth as firebase_auth
            decoded = firebase_auth.verify_id_token(token)
            return {
                "uid": decoded.get("uid", ""),
                "email": decoded.get("email", ""),
                "name": decoded.get("name", "Firebase User"),
            }
        except Exception as e:
            from app.core.exceptions import UnauthorizedException
            raise UnauthorizedException(f"Invalid Firebase token: {str(e)}")

    # Firebase not configured — reject in production, stub in dev
    if settings.is_production:
        from app.core.exceptions import UnauthorizedException
        raise UnauthorizedException("Firebase authentication is not configured")

    # Development fallback — accept token as-is for testing
    return {
        "uid": f"dev-uid-{token[:8]}",
        "email": "dev@fintelia.com",
        "name": "Dev User",
    }
