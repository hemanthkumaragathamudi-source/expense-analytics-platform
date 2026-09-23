import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.models import User, Category, Transaction, CategoryType, TransactionType
from app.core.database import get_db
from app.api.deps import get_current_user
from datetime import date
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

@pytest.fixture(scope="function")
def test_user(db):
    user = User(username="testuser", email="test@example.com", password_hash="hash")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@pytest.fixture(scope="function")
def test_user2(db):
    user = User(username="testuser2", email="test2@example.com", password_hash="hash")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@pytest.fixture(scope="function")
def client_with_db(db, test_user):
    def override_get_db():
        yield db
    def override_get_current_user():
        return test_user
    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_current_user] = override_get_current_user
    yield TestClient(app)
    app.dependency_overrides.clear()

@pytest.fixture(scope="function")
def client_with_db_user2(db, test_user2):
    def override_get_db():
        yield db
    def override_get_current_user():
        return test_user2
    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_current_user] = override_get_current_user
    yield TestClient(app)
    app.dependency_overrides.clear()


def test_create_category(client_with_db):
    response = client_with_db.post(
        "/api/categories/",
        json={"name": "Groceries", "type": "EXPENSE"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Groceries"
    assert data["type"] == "EXPENSE"
    assert "id" in data
    assert "user_id" in data

def test_create_category_duplicate_name(client_with_db):
    client_with_db.post(
        "/api/categories/",
        json={"name": "Duplicate", "type": "EXPENSE"}
    )

    response = client_with_db.post(
        "/api/categories/",
        json={"name": "Duplicate", "type": "INCOME"}
    )
    assert response.status_code == 400

def test_create_category_unauthorized(db):
    def override_get_db():
        yield db
    app.dependency_overrides[get_db] = override_get_db
    # Not overriding get_current_user means it requires valid token, we supply none
    client = TestClient(app)
    response = client.post(
        "/api/categories/",
        json={"name": "Groceries", "type": "EXPENSE"}
    )
    assert response.status_code == 401
    app.dependency_overrides.clear()

def test_list_categories(client_with_db, test_user2, test_user):
    client_with_db.post("/api/categories/", json={"name": "Cat1", "type": "EXPENSE"})

    # Temporarily switch user
    app.dependency_overrides[get_current_user] = lambda: test_user2
    client_with_db.post("/api/categories/", json={"name": "Cat2", "type": "INCOME"})

    # Switch back to test_user
    app.dependency_overrides[get_current_user] = lambda: test_user

    response = client_with_db.get("/api/categories/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["name"] == "Cat1"

def test_get_category(client_with_db):
    create_response = client_with_db.post(
        "/api/categories/",
        json={"name": "GetTest", "type": "EXPENSE"}
    )
    cat_id = create_response.json()["id"]

    response = client_with_db.get(f"/api/categories/{cat_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "GetTest"

def test_get_category_not_found(client_with_db):
    response = client_with_db.get("/api/categories/9999")
    assert response.status_code == 404

def test_get_category_other_user(client_with_db, test_user2, test_user):
    create_response = client_with_db.post(
        "/api/categories/",
        json={"name": "User1Cat", "type": "EXPENSE"}
    )
    cat_id = create_response.json()["id"]

    app.dependency_overrides[get_current_user] = lambda: test_user2
    response = client_with_db.get(f"/api/categories/{cat_id}")
    app.dependency_overrides[get_current_user] = lambda: test_user
    assert response.status_code == 404

def test_update_category(client_with_db):
    create_response = client_with_db.post(
        "/api/categories/",
        json={"name": "OldName", "type": "EXPENSE"}
    )
    cat_id = create_response.json()["id"]

    response = client_with_db.put(
        f"/api/categories/{cat_id}",
        json={"name": "NewName"}
    )
    assert response.status_code == 200
    assert response.json()["name"] == "NewName"
    assert response.json()["type"] == "EXPENSE"

def test_update_category_other_user(client_with_db, test_user2, test_user):
    create_response = client_with_db.post(
        "/api/categories/",
        json={"name": "User1CatUpdate", "type": "EXPENSE"}
    )
    cat_id = create_response.json()["id"]

    app.dependency_overrides[get_current_user] = lambda: test_user2
    response = client_with_db.put(
        f"/api/categories/{cat_id}",
        json={"name": "HackedName"}
    )
    app.dependency_overrides[get_current_user] = lambda: test_user
    assert response.status_code == 404

def test_delete_category(client_with_db):
    create_response = client_with_db.post(
        "/api/categories/",
        json={"name": "ToDelete", "type": "EXPENSE"}
    )
    cat_id = create_response.json()["id"]

    response = client_with_db.delete(f"/api/categories/{cat_id}")
    assert response.status_code == 204

    get_response = client_with_db.get(f"/api/categories/{cat_id}")
    assert get_response.status_code == 404

def test_delete_category_other_user(client_with_db, test_user2, test_user):
    create_response = client_with_db.post(
        "/api/categories/",
        json={"name": "User1CatDelete", "type": "EXPENSE"}
    )
    cat_id = create_response.json()["id"]

    app.dependency_overrides[get_current_user] = lambda: test_user2
    response = client_with_db.delete(f"/api/categories/{cat_id}")
    app.dependency_overrides[get_current_user] = lambda: test_user
    assert response.status_code == 404

def test_delete_category_with_transactions(client_with_db, db):
    cat_response = client_with_db.post(
        "/api/categories/",
        json={"name": "CatWithTx", "type": "EXPENSE"}
    )
    cat_id = cat_response.json()["id"]
    user_id = cat_response.json()["user_id"]

    tx = Transaction(
        user_id=user_id,
        category_id=cat_id,
        date=date(2023, 1, 1),
        amount=100.0,
        transaction_type=TransactionType.EXPENSE,
        description="Test Tx"
    )
    db.add(tx)
    db.commit()

    delete_response = client_with_db.delete(f"/api/categories/{cat_id}")
    assert delete_response.status_code == 400
    assert "referenced" in delete_response.json()["detail"].lower()
