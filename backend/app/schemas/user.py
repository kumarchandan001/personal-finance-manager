"""FINTELIA — User Schemas"""
import uuid
from datetime import datetime
from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    risk_tolerance: str = "moderate"


class UserCreate(UserBase):
    password: str


class UserCreateFirebase(BaseModel):
    firebase_token: str
    full_name: str | None = None


class UserUpdate(BaseModel):
    full_name: str | None = None
    avatar_url: str | None = None
    risk_tolerance: str | None = None
    financial_profile: dict | None = None


class UserResponse(UserBase):
    id: uuid.UUID
    avatar_url: str | None = None
    is_active: bool = True
    created_at: datetime | None = None

    model_config = {"from_attributes": True}


class UserBrief(BaseModel):
    id: uuid.UUID
    email: str
    full_name: str

    model_config = {"from_attributes": True}
