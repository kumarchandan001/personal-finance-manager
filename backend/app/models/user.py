"""
FINTELIA — User Model
"""

import uuid
from datetime import datetime

from sqlalchemy import JSON, Boolean, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base, TimestampMixin, SoftDeleteMixin


class User(Base, TimestampMixin, SoftDeleteMixin):
    """User account model."""

    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(
        primary_key=True, default=uuid.uuid4
    )
    firebase_uid: Mapped[str | None] = mapped_column(
        String(128), unique=True, nullable=True, index=True
    )
    email: Mapped[str] = mapped_column(
        String(255), unique=True, nullable=False, index=True
    )
    hashed_password: Mapped[str | None] = mapped_column(
        String(255), nullable=True
    )
    full_name: Mapped[str] = mapped_column(
        String(255), nullable=False
    )
    avatar_url: Mapped[str | None] = mapped_column(
        String(512), nullable=True
    )
    financial_profile: Mapped[dict | None] = mapped_column(
        JSON, nullable=True
    )
    risk_tolerance: Mapped[str] = mapped_column(
        String(50), default="moderate", nullable=False
    )
    is_active: Mapped[bool] = mapped_column(
        Boolean, default=True, nullable=False
    )

    # Relationships
    transactions = relationship("Transaction", back_populates="user", lazy="selectin")
    budgets = relationship("Budget", back_populates="user", lazy="selectin")
    goals = relationship("Goal", back_populates="user", lazy="selectin")
    subscriptions = relationship("Subscription", back_populates="user", lazy="selectin")
    ai_insights = relationship("AIInsight", back_populates="user", lazy="selectin")
    behavioral_analytics = relationship("BehavioralAnalytics", back_populates="user", lazy="selectin")
