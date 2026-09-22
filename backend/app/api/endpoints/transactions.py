from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.models import Transaction, User, Category, PaymentMethod
from datetime import date
from typing import Optional

from app.models.models import TransactionType
from app.schemas.transaction import TransactionCreate, TransactionResponse, TransactionUpdate
from app.api.deps import get_current_user

router = APIRouter()

@router.post("/", response_model=TransactionResponse, status_code=status.HTTP_201_CREATED)
def create_transaction(
    transaction: TransactionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if transaction.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to create transaction for another user")

    # Check if user exists
    user = db.query(User).filter(User.id == transaction.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Check if category exists
    category = db.query(Category).filter(Category.id == transaction.category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    # Optional: check if category belongs to user? The models imply categories might have user_id,
    # but we can check if category.user_id is None (global) or matches transaction.user_id.
    # The requirement says "referenced user/category/payment method not found".

    # Check if payment method exists (if provided)
    if transaction.payment_method_id:
        payment_method = db.query(PaymentMethod).filter(PaymentMethod.id == transaction.payment_method_id).first()
        if not payment_method:
            raise HTTPException(status_code=404, detail="Payment method not found")

    db_transaction = Transaction(**transaction.model_dump())
    db.add(db_transaction)
    db.commit()
    db.refresh(db_transaction)
    return db_transaction

@router.get("/{transaction_id}", response_model=TransactionResponse)
def get_transaction(
    transaction_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    transaction = db.query(Transaction).filter(Transaction.id == transaction_id, Transaction.user_id == current_user.id).first()
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    return transaction

@router.get("/", response_model=List[TransactionResponse])
def list_transactions(
    user_id: Optional[int] = None,
    category_id: Optional[int] = None,
    transaction_type: Optional[TransactionType] = None,
    start_date: Optional[date] = None,
    end_date: Optional[date] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    query = db.query(Transaction).filter(Transaction.user_id == current_user.id)

    if user_id is not None and user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to access transactions of another user")
    if category_id is not None:
        query = query.filter(Transaction.category_id == category_id)
    if transaction_type is not None:
        query = query.filter(Transaction.transaction_type == transaction_type)
    if start_date is not None:
        query = query.filter(Transaction.date >= start_date)
    if end_date is not None:
        query = query.filter(Transaction.date <= end_date)

    query = query.order_by(Transaction.date.desc(), Transaction.id.desc())
    return query.all()

@router.put("/{transaction_id}", response_model=TransactionResponse)
def update_transaction(
    transaction_id: int,
    transaction_update: TransactionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_transaction = db.query(Transaction).filter(Transaction.id == transaction_id, Transaction.user_id == current_user.id).first()
    if not db_transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    update_data = transaction_update.model_dump(exclude_unset=True)

    if "category_id" in update_data and update_data["category_id"] is not None:
        category = db.query(Category).filter(Category.id == update_data["category_id"]).first()
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")

    if "payment_method_id" in update_data and update_data["payment_method_id"] is not None:
        payment_method = db.query(PaymentMethod).filter(PaymentMethod.id == update_data["payment_method_id"]).first()
        if not payment_method:
            raise HTTPException(status_code=404, detail="Payment method not found")

    for key, value in update_data.items():
        setattr(db_transaction, key, value)

    db.commit()
    db.refresh(db_transaction)
    return db_transaction

@router.delete("/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(
    transaction_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_transaction = db.query(Transaction).filter(Transaction.id == transaction_id, Transaction.user_id == current_user.id).first()
    if not db_transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")

    db.delete(db_transaction)
    db.commit()
    return None
