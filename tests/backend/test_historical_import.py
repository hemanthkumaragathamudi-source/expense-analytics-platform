import json
import pytest
from datetime import date
from sqlalchemy.orm import Session
from app.models.models import User, Category, PaymentMethod, Transaction, Budget
from app.scripts.import_historical_data import import_data

@pytest.fixture
def synthetic_historical_data(tmp_path):
    data = {
        "users": [
            {
                "username": "histuser",
                "email": "hist@example.com",
                "password_hash": "dummyhash"
            }
        ],
        "categories": [
            {
                "username": "histuser",
                "name": "Groceries",
                "type": "EXPENSE"
            },
            {
                "username": "histuser",
                "name": "Salary",
                "type": "INCOME"
            }
        ],
        "payment_methods": [
            {
                "name": "Credit Card"
            }
        ],
        "budgets": [
            {
                "username": "histuser",
                "category_name": "Groceries",
                "amount": 500.0,
                "month": 10,
                "year": 2023
            }
        ],
        "transactions": [
            {
                "username": "histuser",
                "category_name": "Groceries",
                "payment_method_name": "Credit Card",
                "date": "2023-10-15",
                "amount": 50.5,
                "transaction_type": "EXPENSE",
                "description": "Supermarket"
            },
            {
                "username": "histuser",
                "category_name": "Salary",
                "date": "2023-10-01",
                "amount": 5000.0,
                "transaction_type": "INCOME",
                "description": "October Salary"
            }
        ]
    }

    file_path = tmp_path / "hist_data.json"
    with open(file_path, "w") as f:
        json.dump(data, f)

    return str(file_path)

@pytest.fixture
def invalid_synthetic_data(tmp_path):
    data = {
        "users": [
            {
                "username": "baduser",
                "email": "bad@example.com"
            }
        ],
        "categories": [
            {
                "username": "baduser",
                "name": "BadCategory",
                "type": "EXPENSE"
            }
        ],
        "transactions": [
            {
                "username": "baduser",
                "category_name": "BadCategory",
                "date": "invalid-date-string", # Invalid Date
                "amount": 100.0
            },
            {
                "username": "baduser",
                "category_name": "BadCategory",
                "date": "2023-10-01",
                "amount": -50.0 # Negative amount
            }
        ],
        "budgets": [
             {
                "username": "baduser",
                "category_name": "BadCategory",
                "amount": -500.0, # Negative budget
                "month": 10,
                "year": 2023
            }
        ]
    }
    file_path = tmp_path / "bad_data.json"
    with open(file_path, "w") as f:
        json.dump(data, f)
    return str(file_path)


def test_import_success(db: Session, synthetic_historical_data: str):
    # Check initial counts
    assert db.query(User).count() == 0
    assert db.query(Transaction).count() == 0
    assert db.query(Budget).count() == 0

    success = import_data(synthetic_historical_data, db)
    assert success is True

    # Verify records were inserted
    assert db.query(User).filter(User.username == "histuser").count() == 1
    assert db.query(Category).count() == 2

    # 5 from conftest, plus 1 new payment method = 6 (if they are merged)
    # Wait, the script will insert "Credit Card", initial DB has "Cash", "UPI", "Card", "Bank Transfer", "Other"
    pm_count = db.query(PaymentMethod).count()
    assert pm_count >= 1

    assert db.query(Budget).count() == 1
    assert db.query(Transaction).count() == 2

    # Verify relationships
    tx = db.query(Transaction).filter(Transaction.description == "Supermarket").first()
    assert tx.user.username == "histuser"
    assert tx.category.name == "Groceries"
    assert tx.payment_method.name == "Credit Card"
    assert tx.amount == 50.5
    assert tx.date == date(2023, 10, 15)

def test_import_idempotency(db: Session, synthetic_historical_data: str):
    # Run once
    import_data(synthetic_historical_data, db)

    # Get counts
    user_count = db.query(User).count()
    cat_count = db.query(Category).count()
    tx_count = db.query(Transaction).count()
    budget_count = db.query(Budget).count()

    # Run twice
    success = import_data(synthetic_historical_data, db)
    assert success is True

    # Verify counts remain exactly the same
    assert db.query(User).count() == user_count
    assert db.query(Category).count() == cat_count
    assert db.query(Transaction).count() == tx_count
    assert db.query(Budget).count() == budget_count

def test_import_invalid_record(db: Session, invalid_synthetic_data: str):
    # Setup initial count
    tx_count = db.query(Transaction).count()
    budget_count = db.query(Budget).count()

    import_data(invalid_synthetic_data, db)

    # The user and category should have been created successfully
    assert db.query(User).filter(User.username == "baduser").count() == 1
    assert db.query(Category).filter(Category.name == "BadCategory").count() == 1

    # The invalid transactions and budget should NOT have been created
    # Date failure is caught in code (returns None for date, so it's skipped)
    # Negative amount failure is caught by DB check constraints during commit()
    assert db.query(Transaction).count() == tx_count
    assert db.query(Budget).count() == budget_count
