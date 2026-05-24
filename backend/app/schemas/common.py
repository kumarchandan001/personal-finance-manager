"""FINTELIA — Common Schemas"""
from pydantic import BaseModel

class MessageResponse(BaseModel):
    message: str

class PaginatedResponse(BaseModel):
    items: list = []
    total: int = 0
    page: int = 1
    page_size: int = 20
    total_pages: int = 0

class HealthResponse(BaseModel):
    status: str
    environment: str
