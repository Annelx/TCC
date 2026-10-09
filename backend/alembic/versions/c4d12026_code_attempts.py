"""track email verification attempts

Revision ID: c4d12026
Revises: e971ae11a237
"""
from alembic import op
import sqlalchemy as sa

revision = "c4d12026"
down_revision = "e971ae11a237"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("email_verification_tokens", sa.Column("attempts", sa.Integer(), nullable=False, server_default="0"))


def downgrade():
    op.drop_column("email_verification_tokens", "attempts")
