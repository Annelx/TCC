from datetime import date
from decimal import Decimal
from pydantic import BaseModel, ConfigDict, Field, model_validator

class GoalInput(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    target_amount: Decimal = Field(gt=0, max_digits=12, decimal_places=2)
    current_amount: Decimal = Field(ge=0, max_digits=12, decimal_places=2)
    deadline: date

    @model_validator(mode="after")
    def validate_amounts(self):
        if self.current_amount > self.target_amount:
            raise ValueError("Valor atual não pode superar o valor desejado")
        return self

class GoalOutput(GoalInput):
    model_config = ConfigDict(from_attributes=True)
    id: int
    user_id: int
