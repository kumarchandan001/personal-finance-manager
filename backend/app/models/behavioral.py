"""FINTELIA — Behavioral Analytics Model"""
import uuid
from datetime import date
from sqlalchemy import Date, Float, ForeignKey, JSON, String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.base import Base, TimestampMixin

class BehavioralAnalytics(Base, TimestampMixin):
    __tablename__ = "behavioral_analytics"
    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    analysis_type: Mapped[str] = mapped_column(String(50), nullable=False)
    period_start: Mapped[date] = mapped_column(Date, nullable=False)
    period_end: Mapped[date] = mapped_column(Date, nullable=False)
    spending_pattern: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    emotional_spending_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    impulse_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    financial_health_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    behavioral_archetype: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    recommendations: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    user = relationship("User", back_populates="behavioral_analytics")
