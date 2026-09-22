import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.models import User
from app.core.database import get_db

@pytest.fixture(scope="function")
def client_with_db(db):
    def override_get_db():
        yield db
    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()

def test_register_user(client_with_db):
    response = client_with_db.post("/api/auth/register", json={
        "username": "newuser",
        "email": "newuser@example.com",
        "password": "strongpassword"
    })
    assert response.status_code == 201
    data = response.json()
    assert data["username"] == "newuser"
    assert data["email"] == "newuser@example.com"
    assert "id" in data

def test_register_existing_user(client_with_db):
    client_with_db.post("/api/auth/register", json={
        "username": "existinguser",
        "email": "existinguser@example.com",
        "password": "strongpassword"
    })
    response = client_with_db.post("/api/auth/register", json={
        "username": "existinguser",
        "email": "existinguser@example.com",
        "password": "strongpassword"
    })
    assert response.status_code == 400

def test_login_user(client_with_db):
    client_with_db.post("/api/auth/register", json={
        "username": "loginuser",
        "email": "loginuser@example.com",
        "password": "strongpassword"
    })
    response = client_with_db.post("/api/auth/login", data={
        "username": "loginuser",
        "password": "strongpassword"
    })
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_login_invalid_credentials(client_with_db):
    response = client_with_db.post("/api/auth/login", data={
        "username": "nonexistent",
        "password": "badpassword"
    })
    assert response.status_code == 401

def test_get_current_user(client_with_db):
    client_with_db.post("/api/auth/register", json={
        "username": "meuser",
        "email": "meuser@example.com",
        "password": "strongpassword"
    })
    login_resp = client_with_db.post("/api/auth/login", data={
        "username": "meuser",
        "password": "strongpassword"
    })
    token = login_resp.json()["access_token"]

    response = client_with_db.get("/api/auth/me", headers={
        "Authorization": f"Bearer {token}"
    })
    assert response.status_code == 200
    assert response.json()["username"] == "meuser"

def test_protected_route_without_token(client_with_db):
    response = client_with_db.get("/api/transactions/")
    assert response.status_code == 401
