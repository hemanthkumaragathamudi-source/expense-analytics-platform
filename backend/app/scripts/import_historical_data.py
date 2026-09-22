import json
import argparse
import sys
from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
import logging

from app.core.database import SessionLocal
from app.models.models import User, Category, PaymentMethod, Transaction, Budget, CategoryType, TransactionType

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def parse_date(date_str):
    try:
        return datetime.strptime(date_str, "%Y-%m-%d").date()
    except ValueError:
        return None

def import_data(json_file_path: str, db: Session):
    try:
        with open(json_file_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        logger.error(f"Failed to read JSON file: {e}")
        return False

    # Track mapping from old IDs (if present in JSON) to new DB IDs
    user_map = {}
    category_map = {}
    payment_method_map = {}

    try:
        # Import Users
        for u_data in data.get("users", []):
            user = db.query(User).filter(User.email == u_data["email"]).first()
            if not user:
                user = User(
                    username=u_data["username"],
                    email=u_data["email"],
                    password_hash=u_data.get("password_hash", "default_hash")
                )
                db.add(user)
                db.commit()
                db.refresh(user)
                logger.info(f"Imported User: {user.username}")
            else:
                logger.debug(f"User {user.username} already exists.")

            old_id = u_data.get("id")
            if old_id is not None:
                user_map[old_id] = user.id

            # If no old ID, just use the newly generated one mapped to username
            user_map[u_data["username"]] = user.id

        # Import Categories
        for c_data in data.get("categories", []):
            # Resolve user_id
            old_u_id = c_data.get("user_id")
            user_id = None
            if old_u_id is not None:
                user_id = user_map.get(old_u_id)
            elif "username" in c_data:
                user_id = user_map.get(c_data["username"])

            cat_type = CategoryType(c_data["type"].upper()) if "type" in c_data else CategoryType.EXPENSE

            category = db.query(Category).filter(
                Category.user_id == user_id,
                Category.name == c_data["name"]
            ).first()

            if not category:
                category = Category(
                    user_id=user_id,
                    name=c_data["name"],
                    type=cat_type
                )
                db.add(category)
                db.commit()
                db.refresh(category)
                logger.info(f"Imported Category: {category.name}")
            else:
                logger.debug(f"Category {category.name} already exists.")

            old_id = c_data.get("id")
            if old_id is not None:
                category_map[old_id] = category.id
            category_map[c_data["name"]] = category.id

        # Import Payment Methods
        for pm_data in data.get("payment_methods", []):
            pm = db.query(PaymentMethod).filter(PaymentMethod.name == pm_data["name"]).first()
            if not pm:
                pm = PaymentMethod(name=pm_data["name"])
                db.add(pm)
                db.commit()
                db.refresh(pm)
                logger.info(f"Imported Payment Method: {pm.name}")
            else:
                logger.debug(f"Payment Method {pm.name} already exists.")

            old_id = pm_data.get("id")
            if old_id is not None:
                payment_method_map[old_id] = pm.id
            payment_method_map[pm_data["name"]] = pm.id

        # Import Budgets
        for b_data in data.get("budgets", []):
            user_id = user_map.get(b_data.get("user_id")) or user_map.get(b_data.get("username"))
            category_id = category_map.get(b_data.get("category_id")) or category_map.get(b_data.get("category_name"))

            if not user_id or not category_id:
                logger.warning(f"Skipping budget due to missing user or category mapping: {b_data}")
                continue

            budget = db.query(Budget).filter(
                Budget.user_id == user_id,
                Budget.category_id == category_id,
                Budget.month == b_data["month"],
                Budget.year == b_data["year"]
            ).first()

            if not budget:
                budget = Budget(
                    user_id=user_id,
                    category_id=category_id,
                    amount=float(b_data["amount"]),
                    month=int(b_data["month"]),
                    year=int(b_data["year"])
                )
                db.add(budget)
                try:
                    db.commit()
                    logger.info(f"Imported Budget for category ID {category_id}")
                except IntegrityError as e:
                    db.rollback()
                    logger.error(f"Failed to import budget: {e}")
            else:
                logger.debug(f"Budget for {budget.month}/{budget.year} already exists.")

        # Import Transactions
        for t_data in data.get("transactions", []):
            user_id = user_map.get(t_data.get("user_id")) or user_map.get(t_data.get("username"))
            category_id = category_map.get(t_data.get("category_id")) or category_map.get(t_data.get("category_name"))
            pm_id = payment_method_map.get(t_data.get("payment_method_id")) or payment_method_map.get(t_data.get("payment_method_name"))

            if not user_id or not category_id:
                logger.warning(f"Skipping transaction due to missing user or category mapping: {t_data}")
                continue

            tx_date = parse_date(t_data["date"])
            if not tx_date:
                logger.warning(f"Skipping transaction with invalid date: {t_data}")
                continue

            tx_type = TransactionType(t_data["transaction_type"].upper()) if "transaction_type" in t_data else TransactionType.EXPENSE

            # Idempotency check: look for exact match
            tx = db.query(Transaction).filter(
                Transaction.user_id == user_id,
                Transaction.date == tx_date,
                Transaction.category_id == category_id,
                Transaction.amount == float(t_data["amount"]),
                Transaction.description == t_data.get("description")
            ).first()

            if not tx:
                tx = Transaction(
                    user_id=user_id,
                    date=tx_date,
                    category_id=category_id,
                    description=t_data.get("description"),
                    amount=float(t_data["amount"]),
                    transaction_type=tx_type,
                    payment_method_id=pm_id,
                    notes=t_data.get("notes")
                )
                db.add(tx)
                try:
                    db.commit()
                    logger.info(f"Imported Transaction for amount {tx.amount} on {tx.date}")
                except IntegrityError as e:
                    db.rollback()
                    logger.error(f"Failed to import transaction: {e}")
            else:
                logger.debug(f"Transaction on {tx.date} for {tx.amount} already exists.")

        return True

    except Exception as e:
        logger.error(f"An error occurred during import: {e}")
        db.rollback()
        return False

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Import historical data from JSON.")
    parser.add_argument("json_file", type=str, help="Path to the JSON data file")
    args = parser.parse_args()

    db = SessionLocal()
    success = import_data(args.json_file, db)
    db.close()

    if success:
        logger.info("Import completed successfully.")
        sys.exit(0)
    else:
        logger.error("Import failed.")
        sys.exit(1)
