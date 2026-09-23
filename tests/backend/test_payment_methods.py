import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.models.models import Transaction, TransactionType, Category, CategoryType, User
from app.core.database import get_db
from app.api.deps import get_current_user
from datetime import date

@pytest.fixture(scope="function")
def test_user(db):
    user = User(username="testuser_pm", email="testpm@example.com", password_hash="hash")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@pytest.fixture(scope="function")
def test_user2(db):
    user = User(username="testuser2_pm", email="testpm2@example.com", password_hash="hash")
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


def test_create_payment_method(client_with_db):
    response = client_with_db.post(
        "/api/payment-methods/",
        json={"name": "Credit Card Test"}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Credit Card Test"
    assert "id" in data

def test_create_payment_method_duplicate(client_with_db):
    client_with_db.post(
        "/api/payment-methods/",
        json={"name": "Cash Test"}
    )

    response = client_with_db.post(
        "/api/payment-methods/",
        json={"name": "Cash Test"}
    )
    assert response.status_code == 400

def test_create_payment_method_unauthenticated(db):
    def override_get_db():
        yield db
    app.dependency_overrides[get_db] = override_get_db
    client = TestClient(app)
    response = client.post(
        "/api/payment-methods/",
        json={"name": "Bitcoin Test"}
    )
    assert response.status_code == 401
    app.dependency_overrides.clear()

def test_list_payment_methods(client_with_db, client_with_db_user2):
    client_with_db.post("/api/payment-methods/", json={"name": "PM1"})
    client_with_db_user2.post("/api/payment-methods/", json={"name": "PM2"})

    response = client_with_db.get("/api/payment-methods/")
    assert response.status_code == 200
    data = response.json()
    names = [pm["name"] for pm in data]
    assert "PM1" in names
    assert "PM2" in names
    # Initial seeded values might be here too, like "Cash"

def test_get_payment_method(client_with_db):
    create_response = client_with_db.post(
        "/api/payment-methods/",
        json={"name": "GetMe Test"}
    )
    pm_id = create_response.json()["id"]

    response = client_with_db.get(f"/api/payment-methods/{pm_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "GetMe Test"

def test_update_payment_method(client_with_db):
    create_response = client_with_db.post(
        "/api/payment-methods/",
        json={"name": "OldPMName"}
    )
    pm_id = create_response.json()["id"]

    response = client_with_db.put(
        f"/api/payment-methods/{pm_id}",
        json={"name": "NewPMName"}
    )
    assert response.status_code == 200
    assert response.json()["name"] == "NewPMName"

def test_delete_payment_method(client_with_db):
    create_response = client_with_db.post(
        "/api/payment-methods/",
        json={"name": "DeleteMe"}
    )
    pm_id = create_response.json()["id"]

    response = client_with_db.delete(f"/api/payment-methods/{pm_id}")
    assert response.status_code == 204

    get_response = client_with_db.get(f"/api/payment-methods/{pm_id}")
    assert get_response.status_code == 404

def test_delete_payment_method_with_transactions(client_with_db, db, test_user):
    pm_response = client_with_db.post(
        "/api/payment-methods/",
        json={"name": "TxPM"}
    )
    pm_id = pm_response.json()["id"]
    user_id = test_user.id

    cat = Category(user_id=user_id, name="TempCat", type=CategoryType.EXPENSE)
    db.add(cat)
    db.commit()

    tx = Transaction(
        user_id=user_id,
        category_id=cat.id,
        payment_method_id=pm_id,
        date=date(2023, 1, 1),
        amount=100.0,
        transaction_type=TransactionType.EXPENSE,
        description="Test Tx PM"
    )
    db.add(tx)
    db.commit()

    delete_response = client_with_db.delete(f"/api/payment-methods/{pm_id}")
    assert delete_response.status_code == 400
    assert "referenced" in delete_response.json()["detail"].lower()
