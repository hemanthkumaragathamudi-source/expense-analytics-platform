import pytest
from datetime import date
from sqlalchemy.exc import IntegrityError
from app.models.models import User, Category, Transaction, Budget, PaymentMethod, CategoryType, TransactionType

def test_db_connection_and_table_creation(db):
    # Simply testing that we can query an empty table without errors
    users = db.query(User).all()
    assert len(users) == 0

def test_initial_payment_methods_exist(db):
    methods = db.query(PaymentMethod).all()
    assert len(methods) == 5
    names = [m.name for m in methods]
    assert "Cash" in names
    assert "UPI" in names
    assert "Card" in names
    assert "Bank Transfer" in names
    assert "Other" in names

def test_create_user(db):
    user = User(username="testuser", email="test@example.com", password_hash="hashedpassword")
    db.add(user)
    db.commit()

    saved_user = db.query(User).filter(User.username == "testuser").first()
    assert saved_user is not None
    assert saved_user.email == "test@example.com"
    assert saved_user.id is not None

def test_user_unique_constraints(db):
    user1 = User(username="testuser", email="test1@example.com", password_hash="hash")
    db.add(user1)
    db.commit()

    user2 = User(username="testuser", email="test2@example.com", password_hash="hash")
    db.add(user2)
    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()

def test_create_category_and_relationship(db):
    user = User(username="catuser", email="cat@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="Groceries", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    saved_category = db.query(Category).filter(Category.name == "Groceries").first()
    assert saved_category is not None
    assert saved_category.user.username == "catuser"

def test_create_transaction_and_relationships(db):
    user = User(username="transuser", email="trans@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="Food", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    payment_method = db.query(PaymentMethod).filter(PaymentMethod.name == "Card").first()

    transaction = Transaction(
        user_id=user.id,
        date=date(2023, 10, 1),
        category_id=category.id,
        amount=50.0,
        transaction_type=TransactionType.EXPENSE,
        payment_method_id=payment_method.id
    )
    db.add(transaction)
    db.commit()

    saved_transaction = db.query(Transaction).filter(Transaction.user_id == user.id).first()
    assert saved_transaction is not None
    assert saved_transaction.amount == 50.0
    assert saved_transaction.category.name == "Food"
    assert saved_transaction.payment_method.name == "Card"

def test_create_budget(db):
    user = User(username="budgetuser", email="budget@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="Entertainment", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    budget = Budget(
        user_id=user.id,
        category_id=category.id,
        amount=100.0,
        month=10,
        year=2023
    )
    db.add(budget)
    db.commit()

    saved_budget = db.query(Budget).filter(Budget.user_id == user.id).first()
    assert saved_budget is not None
    assert saved_budget.amount == 100.0

def test_transaction_amount_constraint(db):
    user = User(username="neguser", email="neg@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="Rent", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    transaction = Transaction(
        user_id=user.id,
        date=date(2023, 10, 1),
        category_id=category.id,
        amount=-10.0,  # Invalid amount
        transaction_type=TransactionType.EXPENSE
    )
    db.add(transaction)

    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()

def test_budget_unique_constraint(db):
    user = User(username="dupbudgetuser", email="dupbudget@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="Utilities", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    budget1 = Budget(
        user_id=user.id,
        category_id=category.id,
        amount=100.0,
        month=10,
        year=2023
    )
    db.add(budget1)
    db.commit()

    # Duplicate budget for same user, category, month, year
    budget2 = Budget(
        user_id=user.id,
        category_id=category.id,
        amount=200.0,
        month=10,
        year=2023
    )
    db.add(budget2)
    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()

def test_budget_negative_amount_constraint(db):
    user = User(username="budgneguser", email="budgneg@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="Entertainment2", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    budget = Budget(
        user_id=user.id,
        category_id=category.id,
        amount=-50.0,
        month=10,
        year=2023
    )
    db.add(budget)
    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()

def test_budget_month_bounds(db):
    user = User(username="budgmonthuser", email="budgmonth@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="Books", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    # Test lower bound
    budget_low = Budget(
        user_id=user.id,
        category_id=category.id,
        amount=100.0,
        month=0,
        year=2023
    )
    db.add(budget_low)
    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()

    # Test upper bound
    budget_high = Budget(
        user_id=user.id,
        category_id=category.id,
        amount=100.0,
        month=13,
        year=2023
    )
    db.add(budget_high)
    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()

def test_user_cascade_deletion(db):
    user = User(username="cascadeuser", email="cascade@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="CascadeCat", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    budget = Budget(user_id=user.id, category_id=category.id, amount=100.0, month=10, year=2023)
    db.add(budget)
    db.commit()

    transaction = Transaction(
        user_id=user.id,
        date=date(2023, 10, 1),
        category_id=category.id,
        amount=50.0,
        transaction_type=TransactionType.EXPENSE
    )
    db.add(transaction)
    db.commit()

    user_id = user.id
    category_id = category.id
    budget_id = budget.id
    transaction_id = transaction.id

    # Delete the user
    db.delete(user)
    db.commit()

    # Verify everything related is deleted
    assert db.query(User).filter(User.id == user_id).first() is None
    assert db.query(Category).filter(Category.id == category_id).first() is None
    assert db.query(Budget).filter(Budget.id == budget_id).first() is None
    assert db.query(Transaction).filter(Transaction.id == transaction_id).first() is None

def test_category_foreign_key_restriction(db):
    user = User(username="catfkuser", email="catfk@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="CatFK", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    transaction = Transaction(
        user_id=user.id,
        date=date(2023, 10, 1),
        category_id=category.id,
        amount=50.0,
        transaction_type=TransactionType.EXPENSE
    )
    db.add(transaction)
    db.commit()

    # Try to delete the category which is referenced by a transaction
    db.delete(category)
    with pytest.raises(IntegrityError):
        db.commit()
    db.rollback()

def test_payment_method_foreign_key_restriction(db):
    user = User(username="pmfkuser", email="pmfk@example.com", password_hash="hash")
    db.add(user)
    db.commit()

    category = Category(user_id=user.id, name="PMFKCat", type=CategoryType.EXPENSE)
    db.add(category)
    db.commit()

    payment_method = db.query(PaymentMethod).filter(PaymentMethod.name == "Cash").first()

    transaction = Transaction(
        user_id=user.id,
        date=date(2023, 10, 1),
        category_id=category.id,
        amount=50.0,
        transaction_type=TransactionType.EXPENSE,
        payment_method_id=payment_method.id
    )
    db.add(transaction)
    db.commit()

    # Try to delete the payment method which is referenced by a transaction
    # Since payment_method_id is nullable, the ORM might try to set it to NULL instead of deleting it.
    # To test the DB-level RESTRICT constraint, we can execute a delete statement directly.
    from sqlalchemy import delete
    with pytest.raises(IntegrityError):
        db.execute(delete(PaymentMethod).where(PaymentMethod.id == payment_method.id))
        db.commit()
    db.rollback()
