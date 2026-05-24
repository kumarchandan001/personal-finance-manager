"""
FINTELIA — FastAPI Application Entry Point

Production-grade REST API for the FINTELIA ecosystem.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import settings
from app.core.exceptions import register_exception_handlers
from app.database.session import init_db, close_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan handler for startup/shutdown events."""
    # ---- Startup ----
    print(f"FINTELIA API starting in {settings.ENVIRONMENT} mode")

    # Initialize database tables in development
    if settings.is_development:
        await init_db()
        print("Database tables initialized")

    # Initialize Firebase Admin SDK (optional)
    if settings.firebase_enabled:
        try:
            from app.core.security import _ensure_firebase_initialized
            _ensure_firebase_initialized()
            print("Firebase Admin SDK initialized")
        except Exception as e:
            print(f"Firebase init skipped: {e}")
    else:
        print("Firebase not configured — using API-only auth")

    yield

    # ---- Shutdown ----
    await close_db()
    print("FINTELIA API shut down")


app = FastAPI(
    title="FINTELIA API",
    description="AI-Powered Behavioral Personal Finance Management API",
    version="0.1.0",
    docs_url="/docs" if settings.is_development else None,
    redoc_url="/redoc" if settings.is_development else None,
    lifespan=lifespan,
)

# ---- CORS Middleware ----
_cors_origins: list[str] = [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:8000",
    "http://localhost:8080",
    "https://fintelia.com",
    "https://www.fintelia.com",
    "https://app.fintelia.com",
    "https://api.fintelia.com",
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if settings.is_development else _cors_origins,
    allow_origin_regex=(
        r"^https://.*\.fintelia\.com$|^http://localhost:\d+$"
        if not settings.is_development
        else None
    ),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---- Exception Handlers ----
register_exception_handlers(app)

# ---- API Routes ----
app.include_router(api_router, prefix="/api/v1")


# ---- Root Endpoints ----
@app.get("/", tags=["Root"])
async def root():
    """API root — returns service info."""
    return {
        "service": "FINTELIA API",
        "version": "0.1.0",
        "status": "running",
        "environment": settings.ENVIRONMENT,
        "firebase_enabled": settings.firebase_enabled,
        "docs": "/docs",
    }


@app.get("/health", tags=["Root"])
async def health_check():
    """Health check endpoint for monitoring."""
    return {"status": "healthy", "environment": settings.ENVIRONMENT}
