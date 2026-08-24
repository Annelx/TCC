import hashlib
import secrets
from datetime import datetime, timedelta, timezone

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.models.email_verification_token import EmailVerificationToken
from app.models.user import User


VERIFICATION_TOKEN_EXPIRE_MINUTES = 30


def generate_verification_token() -> str:
    return secrets.token_urlsafe(32)


def hash_verification_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def get_token_expiration() -> datetime:
    return datetime.now(timezone.utc) + timedelta(
        minutes=VERIFICATION_TOKEN_EXPIRE_MINUTES
    )


def create_verification_token(
    db: Session,
    user_id: int
) -> str:

    now = datetime.now(timezone.utc)

    # Revoga tokens anteriores ainda ativos
    db.execute(
        update(EmailVerificationToken)
        .where(
            EmailVerificationToken.user_id == user_id,
            EmailVerificationToken.used_at.is_(None),
            EmailVerificationToken.revoked_at.is_(None),
        )
        .values(revoked_at=now)
    )

    # Gera o novo token
    token = generate_verification_token()

    token_hash = hash_verification_token(token)

    verification_token = EmailVerificationToken(
        user_id=user_id,
        token_hash=token_hash,
        expires_at=get_token_expiration(),
        created_at=now,
    )

    db.add(verification_token)
    db.commit()

    return token

def validate_verification_token(
    db: Session,
    token: str
) -> EmailVerificationToken | None:

    token_hash = hash_verification_token(token)

    verification_token = db.scalar(
        select(EmailVerificationToken)
        .where(
            EmailVerificationToken.token_hash == token_hash,
            EmailVerificationToken.used_at.is_(None),
            EmailVerificationToken.revoked_at.is_(None),
        )
    )

    if verification_token is None:
        return None

    now = datetime.now(timezone.utc)

    if verification_token.expires_at <= now:
        return None

    return verification_token

def confirm_email(
    db: Session,
    token: str
) -> User | None:

    verification_token = validate_verification_token(db, token)

    if verification_token is None:
        return None

    user = db.get(User, verification_token.user_id)

    if user is None:
        return None

    now = datetime.now(timezone.utc)

    user.email_verified = True
    verification_token.used_at = now

    db.commit()
    db.refresh(user)

    return user