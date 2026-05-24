"""FINTELIA — Schemas Package"""
from app.schemas.user import UserCreate, UserResponse, UserUpdate, UserBrief
from app.schemas.transaction import TransactionCreate, TransactionUpdate, TransactionResponse, TransactionSummary
from app.schemas.budget import BudgetCreate, BudgetUpdate, BudgetResponse
from app.schemas.goal import GoalCreate, GoalUpdate, GoalResponse
from app.schemas.auth import LoginRequest, TokenResponse, FirebaseLoginRequest, RefreshTokenRequest
from app.schemas.ai import ChatMessage, ChatResponse, AIInsightResponse
from app.schemas.common import MessageResponse, PaginatedResponse

__all__ = [
    "UserCreate", "UserResponse", "UserUpdate", "UserBrief",
    "TransactionCreate", "TransactionUpdate", "TransactionResponse", "TransactionSummary",
    "BudgetCreate", "BudgetUpdate", "BudgetResponse",
    "GoalCreate", "GoalUpdate", "GoalResponse",
    "LoginRequest", "TokenResponse", "FirebaseLoginRequest", "RefreshTokenRequest",
    "ChatMessage", "ChatResponse", "AIInsightResponse",
    "MessageResponse", "PaginatedResponse",
]
