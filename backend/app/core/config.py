"""
FINTELIA — Application Configuration

Uses pydantic-settings for type-safe environment variable management.
"""

import warnings

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://user:password@localhost:5432/fintelia_db"

    # Security
    SECRET_KEY: str = ""
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Firebase
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CREDENTIALS_PATH: str = ""

    # AI
    GEMINI_API_KEY: str = ""

    # Application
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
    )

    @model_validator(mode="after")
    def _validate_production_settings(self) -> "Settings":
        """Ensure critical secrets are set in production."""
        if self.ENVIRONMENT == "production":
            if not self.SECRET_KEY or self.SECRET_KEY in (
                "your-super-secret-key-change-in-production",
                "dev-secret-key-not-for-production-use",
            ):
                raise ValueError(
                    "SECRET_KEY must be set to a strong, unique value in production. "
                    "Generate one with: python -c \"import secrets; print(secrets.token_urlsafe(64))\""
                )
            if self.DEBUG:
                warnings.warn(
                    "DEBUG=true in production — forcing DEBUG=false",
                    RuntimeWarning,
                    stacklevel=2,
                )
                object.__setattr__(self, "DEBUG", False)
        return self

    @property
    def is_development(self) -> bool:
        return self.ENVIRONMENT == "development"

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT == "production"

    @property
    def firebase_enabled(self) -> bool:
        return bool(self.FIREBASE_PROJECT_ID)


settings = Settings()
