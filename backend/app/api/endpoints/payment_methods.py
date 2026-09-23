from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import List
from sqlalchemy import delete

from app.core.database import get_db
from app.models.models import PaymentMethod, User
from app.schemas.payment_method import PaymentMethodCreate, PaymentMethodResponse, PaymentMethodUpdate
from app.api.deps import get_current_user

router = APIRouter()

@router.post("/", response_model=PaymentMethodResponse, status_code=status.HTTP_201_CREATED)
def create_payment_method(
    payment_method: PaymentMethodCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Payment methods are globally shared, check for uniqueness by name
    existing_pm = db.query(PaymentMethod).filter(
        PaymentMethod.name == payment_method.name
    ).first()

    if existing_pm:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Payment method with this name already exists"
        )

    db_payment_method = PaymentMethod(**payment_method.model_dump())
    db.add(db_payment_method)
    db.commit()
    db.refresh(db_payment_method)
    return db_payment_method

@router.get("/", response_model=List[PaymentMethodResponse])
def list_payment_methods(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    return db.query(PaymentMethod).order_by(PaymentMethod.name).all()

@router.get("/{payment_method_id}", response_model=PaymentMethodResponse)
def get_payment_method(
    payment_method_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    payment_method = db.query(PaymentMethod).filter(PaymentMethod.id == payment_method_id).first()
    if not payment_method:
        raise HTTPException(status_code=404, detail="Payment method not found")
    return payment_method

@router.put("/{payment_method_id}", response_model=PaymentMethodResponse)
def update_payment_method(
    payment_method_id: int,
    payment_method_update: PaymentMethodUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_payment_method = db.query(PaymentMethod).filter(PaymentMethod.id == payment_method_id).first()
    if not db_payment_method:
        raise HTTPException(status_code=404, detail="Payment method not found")

    update_data = payment_method_update.model_dump(exclude_unset=True)

    # Check uniqueness if name is updated
    if "name" in update_data and update_data["name"] != db_payment_method.name:
        existing_pm = db.query(PaymentMethod).filter(
            PaymentMethod.name == update_data["name"]
        ).first()

        if existing_pm:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Payment method with this name already exists"
            )

    for key, value in update_data.items():
        setattr(db_payment_method, key, value)

    db.commit()
    db.refresh(db_payment_method)
    return db_payment_method

@router.delete("/{payment_method_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_payment_method(
    payment_method_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_payment_method = db.query(PaymentMethod).filter(PaymentMethod.id == payment_method_id).first()
    if not db_payment_method:
        raise HTTPException(status_code=404, detail="Payment method not found")

    try:
        # Use direct DB execution to avoid ORM automatic foreign key nulling
        # This properly tests and triggers database-level ON DELETE RESTRICT constraints
        db.execute(delete(PaymentMethod).where(PaymentMethod.id == payment_method_id))
        db.commit()
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete payment method because it is referenced by one or more transactions"
        )
    return None
