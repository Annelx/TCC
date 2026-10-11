from datetime import date
from decimal import Decimal
from typing import Literal
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

Money = Decimal

class MainGoal(BaseModel):
    valor_guardar: Money | None = Field(default=None, ge=0, max_digits=12, decimal_places=2)
    valor_atual: Money | None = Field(default=None, ge=0, max_digits=12, decimal_places=2)
    valor_total: Money | None = Field(default=None, ge=0, max_digits=12, decimal_places=2)
    prazo: date | None = None

class OnboardingComplete(BaseModel):
    model_config = ConfigDict(extra="forbid")
    apelido: str = Field(min_length=2, max_length=100)
    email: str | None = None  # Conferido com o usuário autenticado; não altera login.
    renda_mensal: Money = Field(ge=0, max_digits=12, decimal_places=2)
    tipo_renda: Literal["fixa", "variavel", "fixa_variavel"]
    gastos_fixos: dict[str, Money] = Field(default_factory=dict)
    objetivos_selecionados: list[str] = Field(default_factory=list, max_length=30)
    sem_metas: bool = False
    meta_principal: MainGoal | None = None
    dificuldades: list[str] = Field(default_factory=list, max_length=30)
    frequencia_recomendacoes: Literal["sempre", "semanal", "mensal", "sob_demanda"]
    nivel_intervencao: Literal["leve", "moderado", "intenso"]

    @field_validator("gastos_fixos")
    @classmethod
    def validate_expenses(cls, value):
        if len(value) > 50 or any(not key.strip() or len(key) > 100 or amount < 0 or amount > Decimal("9999999999.99") for key, amount in value.items()):
            raise ValueError("Gastos fixos invalidos")
        return value

    @model_validator(mode="after")
    def validate_goal(self):
        if self.sem_metas and self.meta_principal is not None:
            raise ValueError("Meta principal deve ser nula quando sem_metas for verdadeiro")
        return self

class OnboardingResponse(BaseModel):
    message: str
    onboarding_completed: bool
