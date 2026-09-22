from pydantic import BaseModel, Field, field_validator
from datetime import date, datetime
from typing import Optional
from app.models.models import TransactionType

class TransactionBase(BaseModel):
    date: date
    category_id: int
    description: Optional[str] = None
    amount: float = Field(..., gt=0, description="Amount must be greater than 0")
    transaction_type: TransactionType
    payment_method_id: Optional[int] = None
    notes: Optional[str] = None

class TransactionCreate(TransactionBase):
    user_id: int

class TransactionUpdate(BaseModel):
    date: Optional[date] = None
    category_id: Optional[int] = None
    description: Optional[str] = None
    amount: Optional[float] = Field(None, gt=0, description="Amount must be greater than 0")
    transaction_type: Optional[TransactionType] = None
    payment_method_id: Optional[int] = None
    notes: Optional[str] = None

class TransactionResponse(TransactionBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
