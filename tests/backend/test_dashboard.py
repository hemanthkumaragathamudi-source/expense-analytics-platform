import pytest
from fastapi.testclient import TestClient
from datetime import date
from app.main import app
from app.models.models import User, Category, PaymentMethod, Transaction, Budget, CategoryType, TransactionType
from app.core.database import get_db
from app.api.deps import get_current_user

@pytest.fixture(scope="function")
def test_user(db):
    user = User(username="testuser", email="test@example.com", password_hash="hash")
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@pytest.fixture(scope="function")
def other_user(db):
    user = User(username="otheruser", email="other@example.com", password_hash="hash")
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
def unauthenticated_client(db):
    def override_get_db():
        yield db
    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()

@pytest.fixture(scope="function")
def dashboard_data(db, test_user, other_user):
    # Categories
    food_cat = Category(user_id=test_user.id, name="Food", type=CategoryType.EXPENSE)
    travel_cat = Category(user_id=test_user.id, name="Travel", type=CategoryType.EXPENSE)
    salary_cat = Category(user_id=test_user.id, name="Salary", type=CategoryType.INCOME)
    util_cat = Category(user_id=test_user.id, name="Utilities", type=CategoryType.EXPENSE)
    fun_cat = Category(user_id=test_user.id, name="Fun", type=CategoryType.EXPENSE)
    health_cat = Category(user_id=test_user.id, name="Health", type=CategoryType.EXPENSE)
    misc_cat = Category(user_id=test_user.id, name="Misc", type=CategoryType.EXPENSE)

    other_food_cat = Category(user_id=other_user.id, name="Other Food", type=CategoryType.EXPENSE)

    db.add_all([food_cat, travel_cat, salary_cat, util_cat, fun_cat, health_cat, misc_cat, other_food_cat])
    db.commit()

    # Transactions for Oct 2026
    txs = [
        # Income
        Transaction(user_id=test_user.id, date=date(2026, 10, 1), category_id=salary_cat.id, amount=10000.0, transaction_type=TransactionType.INCOME),
        Transaction(user_id=test_user.id, date=date(2026, 10, 15), category_id=salary_cat.id, amount=15000.0, transaction_type=TransactionType.INCOME),

        # Expenses
        Transaction(user_id=test_user.id, date=date(2026, 10, 2), category_id=food_cat.id, amount=2000.0, transaction_type=TransactionType.EXPENSE),
        Transaction(user_id=test_user.id, date=date(2026, 10, 3), category_id=food_cat.id, amount=1000.0, transaction_type=TransactionType.EXPENSE),
        Transaction(user_id=test_user.id, date=date(2026, 10, 4), category_id=travel_cat.id, amount=1500.0, transaction_type=TransactionType.EXPENSE),
        Transaction(user_id=test_user.id, date=date(2026, 10, 5), category_id=util_cat.id, amount=1000.0, transaction_type=TransactionType.EXPENSE),
        Transaction(user_id=test_user.id, date=date(2026, 10, 6), category_id=fun_cat.id, amount=500.0, transaction_type=TransactionType.EXPENSE),
        Transaction(user_id=test_user.id, date=date(2026, 10, 7), category_id=health_cat.id, amount=300.0, transaction_type=TransactionType.EXPENSE),
        Transaction(user_id=test_user.id, date=date(2026, 10, 8), category_id=misc_cat.id, amount=200.0, transaction_type=TransactionType.EXPENSE),

        # Other user
        Transaction(user_id=other_user.id, date=date(2026, 10, 10), category_id=other_food_cat.id, amount=5000.0, transaction_type=TransactionType.EXPENSE),

        # Different month
        Transaction(user_id=test_user.id, date=date(2026, 9, 1), category_id=food_cat.id, amount=100.0, transaction_type=TransactionType.EXPENSE),
    ]
    db.add_all(txs)

    # Budgets
    b1 = Budget(user_id=test_user.id, category_id=food_cat.id, amount=4000.0, month=10, year=2026)
    b2 = Budget(user_id=test_user.id, category_id=travel_cat.id, amount=2000.0, month=10, year=2026)
    b3 = Budget(user_id=other_user.id, category_id=other_food_cat.id, amount=1000.0, month=10, year=2026)

    db.add_all([b1, b2, b3])
    db.commit()

    return {
        "food_cat": food_cat.id,
        "travel_cat": travel_cat.id,
        "salary_cat": salary_cat.id
    }

def test_unauthenticated_rejected(unauthenticated_client):
    response = unauthenticated_client.get("/api/dashboard/?month=10&year=2026")
    assert response.status_code == 401

def test_invalid_month(client_with_db):
    response = client_with_db.get("/api/dashboard/?month=13&year=2026")
    assert response.status_code == 422

def test_dashboard_calculations(client_with_db, dashboard_data):
    response = client_with_db.get("/api/dashboard/?month=10&year=2026")
    assert response.status_code == 200
    data = response.json()

    # Check general params
    assert data["month"] == 10
    assert data["year"] == 2026

    # Check Summary
    summary = data["summary"]
    assert summary["income"] == 25000.0
    assert summary["expenses"] == 6500.0  # 2000+1000+1500+1000+500+300+200
    assert summary["balance"] == 18500.0
    assert summary["transaction_count"] == 9  # 2 income + 7 expense

    # Check Spending by Category
    spending = data["spending_by_category"]
    # Total expenses = 6500
    # Categories: Food (3000), Travel (1500), Util (1000), Fun (500), Health (300), Misc (200) -> 6 categories
    # Should keep top 5, aggregate 1 to Other.
    assert len(spending) == 6
    assert spending[0]["category_name"] == "Food"
    assert spending[0]["amount"] == 3000.0
    assert spending[0]["percentage"] == round((3000 / 6500) * 100, 2)

    assert spending[1]["category_name"] == "Travel"
    assert spending[1]["amount"] == 1500.0
    assert spending[2]["category_name"] == "Utilities"
    assert spending[3]["category_name"] == "Fun"
    assert spending[4]["category_name"] == "Health"

    assert spending[5]["category_name"] == "Other"
    assert spending[5]["amount"] == 200.0
    assert spending[5]["percentage"] == round((200 / 6500) * 100, 2)
    assert spending[5]["category_id"] is None

    # Check Budget
    budget = data["budget"]
    assert budget["total_budget"] == 6000.0
    assert budget["total_expenses"] == 6500.0
    assert budget["remaining"] == -500.0
    assert budget["percentage_used"] == round((6500 / 6000) * 100, 2)
    assert budget["is_over_budget"] is True

    # Check Recent Transactions
    recent = data["recent_transactions"]
    assert len(recent) <= 5
    # Should be sorted date desc, id desc. Last added for Oct 15 is Salary 15000.0
    assert recent[0]["amount"] == 15000.0
    assert recent[0]["category_name"] == "Salary"

    # Check Insight
    insight = data["insight"]
    assert insight["type"] == "largest_category"
    assert "Food" in insight["title"]
    assert "3,000" in insight["description"]

def test_dashboard_user_isolation(client_with_db, dashboard_data, db, test_user, other_user):
    # Other user has $5000 expense, $1000 budget in month 10

    def override_get_current_user_other():
        return other_user

    app.dependency_overrides[get_current_user] = override_get_current_user_other

    response = client_with_db.get("/api/dashboard/?month=10&year=2026")
    assert response.status_code == 200
    data = response.json()

    assert data["summary"]["expenses"] == 5000.0
    assert data["budget"]["total_budget"] == 1000.0

    app.dependency_overrides.clear()

def test_dashboard_empty_data(client_with_db):
    response = client_with_db.get("/api/dashboard/?month=1&year=2020")
    assert response.status_code == 200
    data = response.json()

    assert data["summary"]["income"] == 0.0
    assert data["summary"]["expenses"] == 0.0
    assert data["summary"]["balance"] == 0.0
    assert data["summary"]["transaction_count"] == 0

    assert data["spending_by_category"] == []

    assert data["budget"]["total_budget"] == 0.0
    assert data["budget"]["total_expenses"] == 0.0
    assert data["budget"]["remaining"] == 0.0
    assert data["budget"]["percentage_used"] == 0.0
    assert data["budget"]["is_over_budget"] is False

    assert data["recent_transactions"] == []

    assert data["insight"]["type"] == "none"

def test_dashboard_budget_only(db, client_with_db, test_user):
    food_cat = Category(user_id=test_user.id, name="Food", type=CategoryType.EXPENSE)
    db.add(food_cat)
    db.commit()

    b1 = Budget(user_id=test_user.id, category_id=food_cat.id, amount=4000.0, month=11, year=2026)
    db.add(b1)
    db.commit()

    response = client_with_db.get("/api/dashboard/?month=11&year=2026")
    assert response.status_code == 200
    data = response.json()

    assert data["summary"]["expenses"] == 0.0
    assert data["budget"]["total_budget"] == 4000.0
    assert data["budget"]["remaining"] == 4000.0
    assert data["budget"]["percentage_used"] == 0.0

    assert data["insight"]["type"] == "budget_status"
    assert "within budget" in data["insight"]["title"].lower()
    assert "4,000" in data["insight"]["description"]
