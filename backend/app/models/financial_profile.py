from datetime import datetime, timezone
from sqlalchemy import DateTime, ForeignKey, JSON, String
from sqlalchemy.orm import Mapped, mapped_column
from app.db.base import Base

class FinancialProfile(Base):
    __tablename__ = "financial_profiles"
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False, index=True)
    income_type: Mapped[str] = mapped_column(String(30), nullable=False)
    fixed_expenses: Mapped[dict] = mapped_column(JSON, nullable=False, default=dict)
    selected_goals: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    no_goals: Mapped[bool] = mapped_column(nullable=False, default=False)
    main_goal: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    difficulties: Mapped[list] = mapped_column(JSON, nullable=False, default=list)
    recommendation_frequency: Mapped[str] = mapped_column(String(30), nullable=False)
    intervention_level: Mapped[str] = mapped_column(String(30), nullable=False)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
