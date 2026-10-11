from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, ConfigDict, Field

class TransactionInput(BaseModel):
    description: str = Field(min_length=1, max_length=150)
    amount: Decimal = Field(gt=0, max_digits=12, decimal_places=2)
    category: str = Field(min_length=1, max_length=60)
    is_income: bool
    occurred_at: datetime

class TransactionOutput(TransactionInput):
    model_config = ConfigDict(from_attributes=True)
    id: int
    user_id: int
