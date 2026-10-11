from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.models.financial_profile import FinancialProfile
from app.schemas.onboarding import OnboardingComplete, OnboardingResponse

router = APIRouter(prefix="/onboarding", tags=["Onboarding"])

@router.post("/complete", response_model=OnboardingResponse)
def complete(data: OnboardingComplete, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    if data.email and data.email.strip().lower() != user.email.lower():
        raise HTTPException(422, "O e-mail do perfil deve ser o da conta autenticada")
    profile = db.scalar(select(FinancialProfile).where(FinancialProfile.user_id == user.id))
    if profile is None:
        profile = FinancialProfile(user_id=user.id)
        db.add(profile)
    profile.income_type = data.tipo_renda
    profile.fixed_expenses = {k: float(v) for k, v in data.gastos_fixos.items()}
    profile.selected_goals = data.objetivos_selecionados
    profile.no_goals = data.sem_metas
    profile.main_goal = data.meta_principal.model_dump(mode="json") if data.meta_principal else None
    profile.difficulties = data.dificuldades
    profile.recommendation_frequency = data.frequencia_recomendacoes
    profile.intervention_level = data.nivel_intervencao
    user.name = data.apelido.strip()
    user.monthly_income = data.renda_mensal
    user.onboarding_completed = True
    db.commit()
    return OnboardingResponse(message="Onboarding concluido", onboarding_completed=True)

@router.get("/me")
def get_profile(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    profile = db.scalar(select(FinancialProfile).where(FinancialProfile.user_id == user.id))
    if profile is None:
        raise HTTPException(404, "Perfil financeiro ainda nao cadastrado")
    return {
        "apelido": user.name, "email": user.email, "renda_mensal": str(user.monthly_income),
        "tipo_renda": profile.income_type, "gastos_fixos": profile.fixed_expenses,
        "objetivos_selecionados": profile.selected_goals, "sem_metas": profile.no_goals,
        "meta_principal": profile.main_goal, "dificuldades": profile.difficulties,
        "frequencia_recomendacoes": profile.recommendation_frequency,
        "nivel_intervencao": profile.intervention_level,
    }
