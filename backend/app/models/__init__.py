"""FINTELIA — Models Package. Import all models for Alembic discovery."""
from app.models.user import User
from app.models.transaction import Transaction
from app.models.budget import Budget
from app.models.goal import Goal
from app.models.subscription import Subscription
from app.models.ai_insight import AIInsight
from app.models.behavioral import BehavioralAnalytics

__all__ = [
    "User", "Transaction", "Budget", "Goal",
    "Subscription", "AIInsight", "BehavioralAnalytics",
]
