"""create financial profiles

Revision ID: d6e92026
Revises: c4d12026
"""
from alembic import op
import sqlalchemy as sa
revision = "d6e92026"
down_revision = "c4d12026"
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
        "financial_profiles",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("income_type", sa.String(30), nullable=False),
        sa.Column("fixed_expenses", sa.JSON(), nullable=False),
        sa.Column("selected_goals", sa.JSON(), nullable=False),
        sa.Column("no_goals", sa.Boolean(), nullable=False),
        sa.Column("main_goal", sa.JSON(), nullable=True),
        sa.Column("difficulties", sa.JSON(), nullable=False),
        sa.Column("recommendation_frequency", sa.String(30), nullable=False),
        sa.Column("intervention_level", sa.String(30), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.UniqueConstraint("user_id", name="uq_financial_profiles_user_id"),
    )
    op.create_index("ix_financial_profiles_user_id", "financial_profiles", ["user_id"])

def downgrade():
    op.drop_index("ix_financial_profiles_user_id", table_name="financial_profiles")
    op.drop_table("financial_profiles")
