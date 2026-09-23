from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
from app.models.models import CategoryType

class CategoryBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    type: CategoryType

class CategoryCreate(CategoryBase):
    pass

class CategoryUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    type: Optional[CategoryType] = None

class CategoryResponse(CategoryBase):
    id: int
    user_id: Optional[int] = None
    created_at: datetime

    class Config:
        from_attributes = True
