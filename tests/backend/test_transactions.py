import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.models import User, Category, PaymentMethod, CategoryType, TransactionType
from app.core.database import Base

from app.core.database import get_db

@pytest.fixture(scope="function")
def client_with_db(db):
    def override_get_db():
        yield db
    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()

@pytest.fixture(scope="function")
def setup_data(db):
    user = User(username="testuser", email="test@example.com", password_hash="hash")
    db.add(user)
    db.commit()
    db.refresh(user)

    category = Category(user_id=user.id, name="Food", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()
    db.refresh(category)

    payment_method = db.query(PaymentMethod).first()

    return {
        "user_id": user.id,
        "category_id": category.id,
        "payment_method_id": payment_method.id
    }

def test_create_transaction(client_with_db, setup_data):
    response = client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "payment_method_id": setup_data["payment_method_id"],
        "amount": 100.5,
        "date": "2023-10-01",
        "description": "Lunch",
        "transaction_type": "EXPENSE"
    })
    assert response.status_code == 201
    data = response.json()
    assert data["amount"] == 100.5
    assert data["description"] == "Lunch"
    assert data["transaction_type"] == "EXPENSE"
    assert "id" in data

def test_get_transaction(client_with_db, setup_data):
    create_resp = client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "amount": 50.0,
        "date": "2023-10-02",
        "transaction_type": "EXPENSE"
    })
    tx_id = create_resp.json()["id"]

    response = client_with_db.get(f"/api/transactions/{tx_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == tx_id
    assert data["amount"] == 50.0

def test_get_transaction_not_found(client_with_db):
    response = client_with_db.get("/api/transactions/9999")
    assert response.status_code == 404

def test_update_transaction(client_with_db, setup_data):
    create_resp = client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "amount": 50.0,
        "date": "2023-10-02",
        "transaction_type": "EXPENSE"
    })
    tx_id = create_resp.json()["id"]

    response = client_with_db.put(f"/api/transactions/{tx_id}", json={
        "amount": 75.0,
        "description": "Dinner"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["amount"] == 75.0
    assert data["description"] == "Dinner"

def test_delete_transaction(client_with_db, setup_data):
    create_resp = client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "amount": 50.0,
        "date": "2023-10-02",
        "transaction_type": "EXPENSE"
    })
    tx_id = create_resp.json()["id"]

    response = client_with_db.delete(f"/api/transactions/{tx_id}")
    assert response.status_code == 204

    response_get = client_with_db.get(f"/api/transactions/{tx_id}")
    assert response_get.status_code == 404

def test_create_transaction_invalid_amount(client_with_db, setup_data):
    response = client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "amount": -10.0,
        "date": "2023-10-01",
        "transaction_type": "EXPENSE"
    })
    assert response.status_code == 422  # Pydantic validation error

def test_create_transaction_invalid_user(client_with_db, setup_data):
    response = client_with_db.post("/api/transactions/", json={
        "user_id": 9999,
        "category_id": setup_data["category_id"],
        "amount": 10.0,
        "date": "2023-10-01",
        "transaction_type": "EXPENSE"
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "User not found"

def test_list_transactions(client_with_db, setup_data):
    # Create some transactions
    client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "amount": 10.0,
        "date": "2023-10-01",
        "transaction_type": "EXPENSE"
    })
    client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "amount": 20.0,
        "date": "2023-10-05",
        "transaction_type": "INCOME"
    })

    # List all
    response = client_with_db.get("/api/transactions/")
    assert response.status_code == 200
    assert len(response.json()) >= 2

    # Filter by user_id
    response = client_with_db.get(f"/api/transactions/?user_id={setup_data['user_id']}")
    assert response.status_code == 200
    assert len(response.json()) >= 2

    # Filter by type
    response = client_with_db.get("/api/transactions/?transaction_type=INCOME")
    assert response.status_code == 200
    assert all(tx["transaction_type"] == "INCOME" for tx in response.json())

    # Filter by date range
    response = client_with_db.get("/api/transactions/?start_date=2023-10-02&end_date=2023-10-10")
    assert response.status_code == 200
    assert len(response.json()) >= 1
    assert response.json()[0]["amount"] == 20.0  # The one on 2023-10-05

    # Check ordering (date desc)
    response = client_with_db.get(f"/api/transactions/?user_id={setup_data['user_id']}")
    dates = [tx["date"] for tx in response.json()]
    # Assuming only the two we added
    assert dates[0] >= dates[1]

def test_update_transaction_invalid_category(client_with_db, setup_data):
    create_resp = client_with_db.post("/api/transactions/", json={
        "user_id": setup_data["user_id"],
        "category_id": setup_data["category_id"],
        "amount": 50.0,
        "date": "2023-10-02",
        "transaction_type": "EXPENSE"
    })
    tx_id = create_resp.json()["id"]

    response = client_with_db.put(f"/api/transactions/{tx_id}", json={
        "category_id": 9999
    })
    assert response.status_code == 404
    assert response.json()["detail"] == "Category not found"
