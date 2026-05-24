import pytest
from httpx import AsyncClient, ASGITransport
from unittest.mock import AsyncMock, patch
import uuid

from app.main import app
from app.database.session import get_db

async def override_get_db():
    yield AsyncMock()

app.dependency_overrides[get_db] = override_get_db

@pytest.mark.asyncio
async def test_auth_login_mocked():
    with patch('app.api.v1.auth.AuthService') as mock_auth_service:
        # Setup mock
        mock_instance = AsyncMock()
        mock_instance.login.return_value = {
            "access_token": "mock-jwt-token",
            "token_type": "bearer",
            "refresh_token": "mock-refresh-token",
            "user_id": str(uuid.uuid4())
        }
        mock_auth_service.return_value = mock_instance

        # We must use ASGITransport with AsyncClient for FastAPI apps
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as ac:
            response = await ac.post("/api/v1/auth/login", json={
                "email": "test@example.com",
                "password": "password123"
            })
            
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["access_token"] == "mock-jwt-token"

@pytest.mark.asyncio
async def test_auth_register_mocked():
    with patch('app.api.v1.auth.AuthService') as mock_auth_service:
        mock_instance = AsyncMock()
        mock_instance.register.return_value = {
            "access_token": "mock-jwt-token",
            "token_type": "bearer",
            "refresh_token": "mock-refresh-token",
            "user_id": str(uuid.uuid4())
        }
        mock_auth_service.return_value = mock_instance

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as ac:
            response = await ac.post("/api/v1/auth/register", json={
                "email": "newuser@example.com",
                "password": "password123",
                "full_name": "New User",
                "risk_tolerance": "moderate"
            })
            
        assert response.status_code == 201
        data = response.json()
        assert data["access_token"] == "mock-jwt-token"
