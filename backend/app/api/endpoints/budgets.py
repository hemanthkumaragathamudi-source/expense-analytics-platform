from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.models import Budget, User, Category
from app.schemas.budget import BudgetCreate, BudgetResponse, BudgetUpdate
from app.api.deps import get_current_user

router = APIRouter()

@router.post("/", response_model=BudgetResponse, status_code=status.HTTP_201_CREATED)
def create_budget(
    budget: BudgetCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    # Verify category exists and belongs to the user or is a global category (if applicable)
    # The instructions say: "Verify that the category belongs to the authenticated user. Prevent a user from creating a budget using another user's category."
    category = db.query(Category).filter(Category.id == budget.category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    if category.user_id is not None and category.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to use this category")

    # Verify uniqueness: user_id, category_id, month, year
    existing_budget = db.query(Budget).filter(
        Budget.user_id == current_user.id,
        Budget.category_id == budget.category_id,
        Budget.month == budget.month,
        Budget.year == budget.year
    ).first()

    if existing_budget:
        raise HTTPException(
            status_code=400,
            detail="A budget for this category, month, and year already exists"
        )

    db_budget = Budget(
        user_id=current_user.id,
        category_id=budget.category_id,
        amount=budget.amount,
        month=budget.month,
        year=budget.year
    )
    db.add(db_budget)
    db.commit()
    db.refresh(db_budget)
    return db_budget

@router.get("/", response_model=List[BudgetResponse])
def list_budgets(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    budgets = db.query(Budget).filter(Budget.user_id == current_user.id).order_by(Budget.year.desc(), Budget.month.desc()).all()
    return budgets

@router.get("/{budget_id}", response_model=BudgetResponse)
def get_budget(
    budget_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    budget = db.query(Budget).filter(Budget.id == budget_id).first()
    if not budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    if budget.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to access this budget")

    return budget

@router.put("/{budget_id}", response_model=BudgetResponse)
def update_budget(
    budget_id: int,
    budget_update: BudgetUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_budget = db.query(Budget).filter(Budget.id == budget_id).first()
    if not db_budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    if db_budget.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to update this budget")

    update_data = budget_update.model_dump(exclude_unset=True)

    if "category_id" in update_data and update_data["category_id"] is not None:
        category = db.query(Category).filter(Category.id == update_data["category_id"]).first()
        if not category:
            raise HTTPException(status_code=404, detail="Category not found")
        if category.user_id is not None and category.user_id != current_user.id:
            raise HTTPException(status_code=403, detail="Not authorized to use this category")

    # Check uniqueness if category_id, month, or year are being updated
    new_category_id = update_data.get("category_id", db_budget.category_id)
    new_month = update_data.get("month", db_budget.month)
    new_year = update_data.get("year", db_budget.year)

    if (new_category_id != db_budget.category_id or
        new_month != db_budget.month or
        new_year != db_budget.year):

        existing_budget = db.query(Budget).filter(
            Budget.user_id == current_user.id,
            Budget.category_id == new_category_id,
            Budget.month == new_month,
            Budget.year == new_year,
            Budget.id != budget_id
        ).first()

        if existing_budget:
            raise HTTPException(
                status_code=400,
                detail="A budget for this category, month, and year already exists"
            )

    for key, value in update_data.items():
        setattr(db_budget, key, value)

    db.commit()
    db.refresh(db_budget)
    return db_budget

@router.delete("/{budget_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_budget(
    budget_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    db_budget = db.query(Budget).filter(Budget.id == budget_id).first()
    if not db_budget:
        raise HTTPException(status_code=404, detail="Budget not found")
    if db_budget.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized to delete this budget")

    db.delete(db_budget)
    db.commit()
    return None
