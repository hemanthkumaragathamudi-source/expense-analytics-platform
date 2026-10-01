from typing import List, Optional
from datetime import date
from pydantic import BaseModel, ConfigDict
from app.models.models import TransactionType

class DashboardSummary(BaseModel):
    income: float
    expenses: float
    balance: float
    transaction_count: int

class CategorySpending(BaseModel):
    category_id: Optional[int]
    category_name: str
    amount: float
    percentage: float

class DashboardBudget(BaseModel):
    total_budget: float
    total_expenses: float
    remaining: float
    percentage_used: float
    is_over_budget: bool

class DashboardRecentTransaction(BaseModel):
    id: int
    category_id: int
    category_name: str
    description: Optional[str] = None
    date: date
    amount: float
    transaction_type: TransactionType

    model_config = ConfigDict(from_attributes=True)

class DashboardInsight(BaseModel):
    type: str
    title: Optional[str]
    description: Optional[str]

class DashboardResponse(BaseModel):
    month: int
    year: int
    summary: DashboardSummary
    spending_by_category: List[CategorySpending]
    budget: DashboardBudget
    recent_transactions: List[DashboardRecentTransaction]
    insight: DashboardInsight
