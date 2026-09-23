from pydantic import BaseModel, Field
from typing import Optional

class PaymentMethodBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)

class PaymentMethodCreate(PaymentMethodBase):
    pass

class PaymentMethodUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)

class PaymentMethodResponse(PaymentMethodBase):
    id: int

    class Config:
        from_attributes = True
