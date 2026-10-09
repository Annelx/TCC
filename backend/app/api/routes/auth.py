from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.security import hash_password, verify_password
from app.db.database import get_db
from app.models.user import User
from app.schemas.auth import (EmailCodeRequest, EmailResendRequest, TokenResponse,
                              UserLogin, UserRegister, UserResponse)
from app.services.jwt_service import create_access_token
from app.services.verification_service import (RESEND_INTERVAL, create_verification_code,
                                                latest_code, send_verification_code, verify_code)

router = APIRouter(prefix="/auth", tags=["Autenticacao"])


@router.post("/register", response_model=UserResponse, status_code=201)
def register(data: UserRegister, db: Session = Depends(get_db)):
    email = str(data.email).strip().lower()
    if db.scalar(select(User).where(User.email == email)):
        raise HTTPException(409, "E-mail ja cadastrado")
    user = User(name=data.name.strip(), email=email, password_hash=hash_password(data.password),
                email_verified=False, onboarding_completed=False)
    db.add(user)
    db.flush()
    code = create_verification_code(db, user.id)
    try:
        send_verification_code(email, code)
    except Exception:
        db.rollback()
        raise HTTPException(503, "Nao foi possivel enviar o codigo. Tente novamente.")
    db.commit()
    db.refresh(user)
    return user


@router.post("/verify-code", response_model=UserResponse)
def confirm(data: EmailCodeRequest, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.email == str(data.email).lower()))
    if not user or user.email_verified or not verify_code(db, user, data.code):
        raise HTTPException(400, "Codigo invalido, expirado ou limite de tentativas excedido")
    db.refresh(user)
    return user


@router.post("/resend-code", status_code=200)
def resend(data: EmailResendRequest, db: Session = Depends(get_db)):
    generic = {"message": "Se o cadastro estiver pendente, um codigo sera enviado."}
    user = db.scalar(select(User).where(User.email == str(data.email).lower()))
    if not user or user.email_verified:
        return generic
    previous = latest_code(db, user.id)
    if previous and datetime.now(timezone.utc) - previous.created_at < RESEND_INTERVAL:
        raise HTTPException(429, "Aguarde 60 segundos antes de solicitar outro codigo")
    code = create_verification_code(db, user.id)
    try:
        send_verification_code(user.email, code)
    except Exception:
        db.rollback()
        raise HTTPException(503, "Nao foi possivel enviar o codigo")
    db.commit()
    return generic


@router.post("/login", response_model=TokenResponse)
def login(data: UserLogin, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.email == str(data.email).lower()))
    if user is None or not verify_password(data.password, user.password_hash):
        raise HTTPException(401, "E-mail ou senha invalidos")
    if not user.email_verified:
        raise HTTPException(403, "E-mail ainda nao verificado")
    return TokenResponse(access_token=create_access_token(user.id), token_type="bearer")


@router.get("/me", response_model=UserResponse)
def me(current_user: User = Depends(get_current_user)):
    return current_user
