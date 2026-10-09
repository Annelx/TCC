from typing import Literal
from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


class UserRegister(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

    @field_validator("password")
    @classmethod
    def strong_password(cls, value: str) -> str:
        if not any(c.isalpha() for c in value) or not any(c.isdigit() for c in value):
            raise ValueError("Senha deve conter letras e numeros")
        return value


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    email: EmailStr
    email_verified: bool
    onboarding_completed: bool


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class EmailCodeRequest(BaseModel):
    email: EmailStr
    code: str = Field(pattern=r"^[0-9]{6}$")


class EmailResendRequest(BaseModel):
    email: EmailStr


class TokenResponse(BaseModel):
    access_token: str
    token_type: Literal["bearer"] = "bearer"
