"""Resumo e padrões financeiros calculados exclusivamente com dados do usuário autenticado."""
from collections import defaultdict
from datetime import datetime, timezone
from decimal import Decimal
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.models.transaction import Transaction
from app.models.goal import Goal

router = APIRouter(prefix='/dashboard', tags=['Dashboard e análise financeira'])
ZERO = Decimal('0.00')


def _period(year: int, month: int):
    start = datetime(year, month, 1, tzinfo=timezone.utc)
    end = datetime(year + 1, 1, 1, tzinfo=timezone.utc) if month == 12 else datetime(year, month + 1, 1, tzinfo=timezone.utc)
    return start, end


def _totals(rows):
    income = sum((t.amount for t in rows if t.is_income), ZERO)
    expense = sum((t.amount for t in rows if not t.is_income), ZERO)
    return income, expense


@router.get('/summary')
def summary(
    year: int = Query(default=None, ge=2000, le=2100),
    month: int = Query(default=None, ge=1, le=12),
    user: User = Depends(get_current_user), db: Session = Depends(get_db),
):
    now = datetime.now(timezone.utc)
    year = year or now.year
    month = month or now.month
    start, end = _period(year, month)
    rows = db.scalars(select(Transaction).where(
        Transaction.user_id == user.id,
        Transaction.occurred_at >= start,
        Transaction.occurred_at < end,
    ).order_by(Transaction.occurred_at.desc(), Transaction.id.desc())).all()
    income, expense = _totals(rows)
    category_amounts = defaultdict(lambda: ZERO)
    for t in rows:
        if not t.is_income:
            category_amounts[t.category] += t.amount
    categories = [
        {'name': name, 'amount': str(amount), 'percentage': round(float(amount / expense * 100), 2) if expense else 0}
        for name, amount in sorted(category_amounts.items(), key=lambda x: (-x[1], x[0]))
    ]
    goals = db.scalars(select(Goal).where(Goal.user_id == user.id).order_by(Goal.deadline, Goal.id)).all()
    goal_items = [{
        'id': g.id, 'name': g.name, 'target_amount': str(g.target_amount),
        'current_amount': str(g.current_amount),
        'progress': round(min(float(g.current_amount / g.target_amount), 1.0), 4) if g.target_amount > 0 else 0,
    } for g in goals]
    previous_year, previous_month = (year - 1, 12) if month == 1 else (year, month - 1)
    previous_start, _ = _period(previous_year, previous_month)
    previous_rows = db.scalars(select(Transaction).where(
        Transaction.user_id == user.id,
        Transaction.occurred_at >= previous_start,
        Transaction.occurred_at < start,
    )).all()
    _, previous_expense = _totals(previous_rows)
    change = round(float((expense - previous_expense) / previous_expense * 100), 2) if previous_expense > 0 else None
    monthly_income = user.monthly_income or ZERO
    commitment = round(float(expense / monthly_income * 100), 2) if monthly_income > 0 else None
    insights = []
    if not rows:
        insights.append('Registre transações neste mês para identificar padrões de consumo.')
    if categories and categories[0]['percentage'] >= 40:
        insights.append(f"{categories[0]['name']} concentra {categories[0]['percentage']:.0f}% das despesas deste mês.")
    if change is not None and change >= 20:
        insights.append(f'Suas despesas aumentaram {change:.1f}% em relação ao mês anterior.')
    elif change is not None and change <= -20:
        insights.append(f'Suas despesas diminuíram {abs(change):.1f}% em relação ao mês anterior.')
    if commitment is not None and commitment >= 80:
        insights.append(f'As despesas registradas representam {commitment:.1f}% da renda mensal informada.')
    if expense > income and rows:
        insights.append('As despesas registradas superam as receitas registradas neste mês.')
    return {
        'year': year, 'month': month,
        'income': str(income), 'expenses': str(expense), 'balance': str(income - expense),
        'monthly_income_declared': str(monthly_income), 'income_commitment_percentage': commitment,
        'previous_month_expenses': str(previous_expense), 'expense_change_percentage': change,
        'categories': categories, 'goals': goal_items, 'insights': insights,
        'recent_transactions': [{
            'id': t.id, 'description': t.description, 'amount': str(t.amount),
            'category': t.category, 'is_income': t.is_income, 'occurred_at': t.occurred_at.isoformat(),
        } for t in rows[:5]],
    }
