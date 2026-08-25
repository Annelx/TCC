from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.db.database import get_db
from app.models.user import User
from app.schemas.auth import UserRegister, UserResponse
from app.services.verification_service import (
    confirm_email,
    create_verification_token,
)


router = APIRouter(
    prefix="/auth",
    tags=["Autenticação"]
)


@router.post("/register", response_model=UserResponse)
def register(
    user_data: UserRegister,
    db: Session = Depends(get_db)
):
    existing_user = db.scalar(
        select(User).where(User.email == user_data.email)
    )

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="E-mail já cadastrado"
        )

    hashed_password = hash_password(user_data.password)

    new_user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=hashed_password,
        email_verified=False,
        onboarding_completed=False
    )

    db.add(new_user)

    db.flush()

    create_verification_token(db, new_user.id)

    db.commit()
    db.refresh(new_user)

    return new_user

@router.get("/verify-email", response_model=UserResponse)
def verify_email(
    token: str = Query(..., min_length=1),
    db: Session = Depends(get_db),
):
    user = confirm_email(db, token)

    if not user:
        raise HTTPException(
            status_code=400,
            detail="Token de verificação inválido, expirado ou já utilizado",
        )

    return user