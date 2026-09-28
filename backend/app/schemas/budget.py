from pydantic import BaseModel, Field
from typing import Optional

class BudgetBase(BaseModel):
    category_id: int
    amount: float = Field(..., ge=0.0, description="Budget amount must be non-negative")
    month: int = Field(..., ge=1, le=12, description="Month must be between 1 and 12")
    year: int = Field(..., ge=1900, description="Year must be a valid four-digit year")

class BudgetCreate(BudgetBase):
    pass

class BudgetUpdate(BaseModel):
    category_id: Optional[int] = None
    amount: Optional[float] = Field(None, ge=0.0, description="Budget amount must be non-negative")
    month: Optional[int] = Field(None, ge=1, le=12, description="Month must be between 1 and 12")
    year: Optional[int] = Field(None, ge=1900, description="Year must be a valid four-digit year")

class BudgetResponse(BudgetBase):
    id: int
    user_id: int

    class Config:
        from_attributes = True
