"""create goals

Revision ID: f4a12026
Revises: e7a32026
"""
from alembic import op
import sqlalchemy as sa

revision = "f4a12026"
down_revision = "e7a32026"
branch_labels = None
depends_on = None

def upgrade():
    op.create_table(
        "goals",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("user_id", sa.Integer(), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("target_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("current_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("deadline", sa.Date(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    )
    op.create_index("ix_goals_user_id", "goals", ["user_id"])

def downgrade():
    op.drop_index("ix_goals_user_id", table_name="goals")
    op.drop_table("goals")
