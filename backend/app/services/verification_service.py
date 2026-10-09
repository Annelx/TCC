import hashlib
import hmac
import logging
import secrets
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.email_verification_token import EmailVerificationToken
from app.models.user import User

logger = logging.getLogger("valora.auth")
CODE_LIFETIME = timedelta(minutes=10)
RESEND_INTERVAL = timedelta(seconds=60)
MAX_ATTEMPTS = 5


def _hash(user_id: int, code: str) -> str:
    payload = f"{user_id}:{code}".encode()
    return hmac.new(settings.secret_key.encode(), payload, hashlib.sha256).hexdigest()


def create_verification_code(db: Session, user_id: int) -> str:
    now = datetime.now(timezone.utc)
    db.execute(update(EmailVerificationToken).where(
        EmailVerificationToken.user_id == user_id,
        EmailVerificationToken.used_at.is_(None),
        EmailVerificationToken.revoked_at.is_(None),
    ).values(revoked_at=now))
    code = f"{secrets.randbelow(1_000_000):06d}"
    db.add(EmailVerificationToken(user_id=user_id, token_hash=_hash(user_id, code),
                                  expires_at=now + CODE_LIFETIME, created_at=now,
                                  attempts=0))
    return code


def latest_code(db: Session, user_id: int):
    return db.scalar(select(EmailVerificationToken).where(
        EmailVerificationToken.user_id == user_id,
        EmailVerificationToken.used_at.is_(None),
        EmailVerificationToken.revoked_at.is_(None),
    ).order_by(EmailVerificationToken.created_at.desc()).limit(1))


def verify_code(db: Session, user: User, code: str) -> bool:
    now = datetime.now(timezone.utc)
    token = latest_code(db, user.id)
    if token is None or token.expires_at <= now:
        return False
    if token.attempts >= MAX_ATTEMPTS:
        token.revoked_at = now
        db.commit()
        return False
    token.attempts += 1
    valid = hmac.compare_digest(token.token_hash, _hash(user.id, code))
    if valid:
        token.used_at = now
        user.email_verified = True
    elif token.attempts >= MAX_ATTEMPTS:
        token.revoked_at = now
    db.commit()
    return valid


def send_verification_code(email: str, code: str) -> None:
    if settings.email_mode == "console":
        logger.warning("[VALORA DEV] Codigo de verificacao para %s: %s", email, code)
        return
    if settings.email_mode != "smtp":
        raise RuntimeError("EMAIL_MODE invalido")
    import smtplib
    from email.message import EmailMessage
    if not all([settings.smtp_host, settings.smtp_from, settings.smtp_user, settings.smtp_password]):
        raise RuntimeError("Configuracao SMTP incompleta")
    msg = EmailMessage()
    msg["From"] = settings.smtp_from
    msg["To"] = email
    msg["Subject"] = "Valora - codigo de verificacao"
    msg.set_content(f"Seu codigo de verificacao Valora e: {code}. Valido por 10 minutos.")
    with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=15) as server:
        server.starttls()
        server.login(settings.smtp_user, settings.smtp_password)
        server.send_message(msg)
