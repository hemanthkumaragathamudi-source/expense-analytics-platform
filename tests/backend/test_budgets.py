import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.api.deps import get_current_user
from app.models.models import Budget, Category, User, CategoryType

def create_test_category(db, user_id, name="Test Category", type=CategoryType.EXPENSE):
    category = Category(user_id=user_id, name=name, type=type)
    db.add(category)
    db.commit()
    db.refresh(category)
    return category

def create_test_budget(db, user_id, category_id, amount=100.0, month=1, year=2024):
    budget = Budget(user_id=user_id, category_id=category_id, amount=amount, month=month, year=year)
    db.add(budget)
    db.commit()
    db.refresh(budget)
    return budget

@pytest.fixture
def other_user(db):
    user = User(username="otheruser", email="otheruser@example.com", password_hash="hashed")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@pytest.fixture
def test_user(db):
    user = User(username="testuser_budget", email="testuser_budget@example.com", password_hash="hashed")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def authorized_client(db, test_user):
    from app.core.database import get_db
    def override_get_db():
        yield db
    def override_get_current_user():
        return test_user
    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[get_current_user] = override_get_current_user
    yield TestClient(app)
    app.dependency_overrides.clear()

def test_unauthenticated_access(client: TestClient):
    response = client.post("/api/budgets/", json={"category_id": 1, "amount": 100, "month": 1, "year": 2024})
    assert response.status_code == 401

    response = client.get("/api/budgets/")
    assert response.status_code == 401

    response = client.get("/api/budgets/1")
    assert response.status_code == 401

    response = client.put("/api/budgets/1", json={"amount": 200})
    assert response.status_code == 401

    response = client.delete("/api/budgets/1")
    assert response.status_code == 401

def test_create_budget_success(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    payload = {
        "category_id": category.id,
        "amount": 150.0,
        "month": 5,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["amount"] == 150.0
    assert data["month"] == 5
    assert data["year"] == 2024
    assert data["category_id"] == category.id
    assert data["user_id"] == test_user.id
    assert "id" in data

def test_create_budget_invalid_amount(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    payload = {
        "category_id": category.id,
        "amount": -10.0,
        "month": 5,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 422

def test_create_budget_invalid_month(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    payload = {
        "category_id": category.id,
        "amount": 100.0,
        "month": 13,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 422

def test_create_budget_nonexistent_category(authorized_client, test_user):
    payload = {
        "category_id": 9999,
        "amount": 100.0,
        "month": 5,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 404

def test_create_budget_other_user_category(authorized_client, db, other_user):
    category = create_test_category(db, other_user.id)
    payload = {
        "category_id": category.id,
        "amount": 100.0,
        "month": 5,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 403

def test_create_budget_duplicate(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    create_test_budget(db, test_user.id, category.id, 100.0, 5, 2024)
    payload = {
        "category_id": category.id,
        "amount": 200.0,
        "month": 5,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 400

def test_list_budgets(authorized_client, db, test_user, other_user):
    category1 = create_test_category(db, test_user.id, "Cat 1")
    category2 = create_test_category(db, test_user.id, "Cat 2")
    other_category = create_test_category(db, other_user.id, "Other Cat")

    create_test_budget(db, test_user.id, category1.id, 100, 1, 2024)
    create_test_budget(db, test_user.id, category2.id, 200, 2, 2024)
    create_test_budget(db, other_user.id, other_category.id, 300, 1, 2024)

    response = authorized_client.get("/api/budgets/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2
    assert all(b["user_id"] == test_user.id for b in data)

def test_get_budget(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    budget = create_test_budget(db, test_user.id, category.id)

    response = authorized_client.get(f"/api/budgets/{budget.id}")
    assert response.status_code == 200
    assert response.json()["id"] == budget.id

def test_get_other_user_budget(authorized_client, db, other_user):
    category = create_test_category(db, other_user.id)
    budget = create_test_budget(db, other_user.id, category.id)

    response = authorized_client.get(f"/api/budgets/{budget.id}")
    assert response.status_code == 403

def test_get_nonexistent_budget(authorized_client):
    response = authorized_client.get("/api/budgets/9999")
    assert response.status_code == 404

def test_update_budget_success(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    budget = create_test_budget(db, test_user.id, category.id, 100.0, 1, 2024)

    payload = {
        "amount": 150.0,
        "month": 2
    }
    response = authorized_client.put(f"/api/budgets/{budget.id}", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["amount"] == 150.0
    assert data["month"] == 2
    assert data["year"] == 2024

def test_update_budget_invalid_amount(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    budget = create_test_budget(db, test_user.id, category.id)

    payload = {
        "amount": -50.0
    }
    response = authorized_client.put(f"/api/budgets/{budget.id}", json=payload)
    assert response.status_code == 422

def test_update_budget_other_user_category(authorized_client, db, test_user, other_user):
    category1 = create_test_category(db, test_user.id)
    other_category = create_test_category(db, other_user.id, "Other Cat")
    budget = create_test_budget(db, test_user.id, category1.id)

    payload = {
        "category_id": other_category.id
    }
    response = authorized_client.put(f"/api/budgets/{budget.id}", json=payload)
    assert response.status_code == 403

def test_update_other_user_budget(authorized_client, db, other_user):
    category = create_test_category(db, other_user.id)
    budget = create_test_budget(db, other_user.id, category.id)

    payload = {
        "amount": 200.0
    }
    response = authorized_client.put(f"/api/budgets/{budget.id}", json=payload)
    assert response.status_code == 403

def test_update_budget_duplicate(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    create_test_budget(db, test_user.id, category.id, 100.0, 1, 2024)
    budget2 = create_test_budget(db, test_user.id, category.id, 200.0, 2, 2024)

    payload = {
        "month": 1
    }
    response = authorized_client.put(f"/api/budgets/{budget2.id}", json=payload)
    assert response.status_code == 400

def test_delete_budget_success(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    budget = create_test_budget(db, test_user.id, category.id)

    response = authorized_client.delete(f"/api/budgets/{budget.id}")
    assert response.status_code == 204

    # Verify it's deleted
    response = authorized_client.get(f"/api/budgets/{budget.id}")
    assert response.status_code == 404

def test_delete_other_user_budget(authorized_client, db, other_user):
    category = create_test_category(db, other_user.id)
    budget = create_test_budget(db, other_user.id, category.id)

    response = authorized_client.delete(f"/api/budgets/{budget.id}")
    assert response.status_code == 403

def test_delete_nonexistent_budget(authorized_client):
    response = authorized_client.delete("/api/budgets/9999")
    assert response.status_code == 404


def test_create_budget_zero_amount(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    payload = {
        "category_id": category.id,
        "amount": 0.0,
        "month": 5,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 422

def test_update_budget_zero_amount(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    budget = create_test_budget(db, test_user.id, category.id, 100.0, 1, 2024)
    payload = {
        "amount": 0.0
    }
    response = authorized_client.put(f"/api/budgets/{budget.id}", json=payload)
    assert response.status_code == 422

def test_create_budget_invalid_year_too_large(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    payload = {
        "category_id": category.id,
        "amount": 100.0,
        "month": 5,
        "year": 10000
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 422

def test_update_budget_invalid_year_too_large(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    budget = create_test_budget(db, test_user.id, category.id, 100.0, 1, 2024)
    payload = {
        "year": 10000
    }
    response = authorized_client.put(f"/api/budgets/{budget.id}", json=payload)
    assert response.status_code == 422

def test_create_budget_global_category_rejected(authorized_client, db, test_user):
    # A category with user_id=None
    category = create_test_category(db, None, "Global Category")
    payload = {
        "category_id": category.id,
        "amount": 100.0,
        "month": 5,
        "year": 2024
    }
    response = authorized_client.post("/api/budgets/", json=payload)
    assert response.status_code == 403

def test_update_budget_global_category_rejected(authorized_client, db, test_user):
    category = create_test_category(db, test_user.id)
    budget = create_test_budget(db, test_user.id, category.id, 100.0, 1, 2024)

    global_category = create_test_category(db, None, "Global Category")

    payload = {
        "category_id": global_category.id
    }
    response = authorized_client.put(f"/api/budgets/{budget.id}", json=payload)
    assert response.status_code == 403
