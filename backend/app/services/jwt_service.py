from datetime import datetime, timedelta, timezone

import jwt

from app.core.config import settings


def create_access_token(user_id: int) -> str:
    now = datetime.now(timezone.utc)

    expires_at = now + timedelta(
        minutes=settings.access_token_expire_minutes
    )

    payload = {
        "sub": str(user_id),
        "iat": now,
        "exp": expires_at,
    }

    return jwt.encode(
        payload,
        settings.secret_key,
        algorithm=settings.jwt_algorithm,
    )


def decode_access_token(token: str) -> dict | None:
    try:
        payload = jwt.decode(
            token,
            settings.secret_key,
            algorithms=[settings.jwt_algorithm],
        )

        return payload

    except jwt.InvalidTokenError:
        return None