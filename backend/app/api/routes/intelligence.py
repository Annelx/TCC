"""Análises determinísticas baseadas nas transações do usuário autenticado."""
from collections import defaultdict
from datetime import datetime, timezone
from decimal import Decimal
from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.transaction import Transaction
from app.models.user import User

router = APIRouter(prefix="/intelligence", tags=["Inteligência financeira"])


def month_bounds(year, month):
    start = datetime(year, month, 1, tzinfo=timezone.utc)
    end = datetime(year + (month == 12), month % 12 + 1, 1, tzinfo=timezone.utc)
    return start, end


@router.get("/insights")
def insights(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    now = datetime.now(timezone.utc)
    start, end = month_bounds(now.year, now.month)
    prev_year, prev_month = (now.year - 1, 12) if now.month == 1 else (now.year, now.month - 1)
    previous_start, _ = month_bounds(prev_year, prev_month)
    rows = db.scalars(select(Transaction).where(
        Transaction.user_id == user.id,
        Transaction.occurred_at >= previous_start,
        Transaction.occurred_at < end,
    )).all()
    current = [r for r in rows if start <= r.occurred_at.astimezone(timezone.utc) < end and not r.is_income]
    previous = [r for r in rows if previous_start <= r.occurred_at.astimezone(timezone.utc) < start and not r.is_income]
    total = sum((r.amount for r in current), Decimal('0'))
    previous_total = sum((r.amount for r in previous), Decimal('0'))
    by_category = defaultdict(lambda: Decimal('0'))
    for row in current:
        by_category[row.category] += row.amount
    alerts = []
    def add(code, level, title, message):
        alerts.append({'code': code, 'level': level, 'title': title, 'message': message})
    if not current:
        add('insufficient_data', 'info', 'Comece a registrar despesas', 'Cadastre despesas neste mês para receber análises personalizadas.')
    else:
        category, amount = max(by_category.items(), key=lambda item: item[1])
        percentage = amount / total * 100 if total else Decimal('0')
        if percentage >= 40:
            add('category_concentration', 'warning', 'Concentração de gastos', f'{category} representa {percentage:.1f}% das despesas do mês. Avalie oportunidades de economia nessa categoria.')
        if previous_total > 0:
            change = (total - previous_total) / previous_total * 100
            if change >= 20:
                add('expense_increase', 'warning', 'Despesas em alta', f'Seus gastos aumentaram {change:.1f}% em relação ao mês anterior.')
            elif change <= -20:
                add('expense_decrease', 'success', 'Despesas em queda', f'Seus gastos diminuíram {abs(change):.1f}% em relação ao mês anterior.')
        if user.monthly_income and user.monthly_income > 0:
            commitment = total / user.monthly_income * 100
            if commitment >= 100:
                add('income_exceeded', 'critical', 'Despesas acima da renda', 'As despesas registradas neste mês ultrapassaram sua renda mensal declarada.')
            elif commitment >= 80:
                add('income_commitment', 'warning', 'Atenção ao orçamento', f'Você já comprometeu {commitment:.1f}% da renda mensal declarada.')
    return {
        'year': now.year, 'month': now.month,
        'total_expenses': str(total), 'previous_month_expenses': str(previous_total),
        'category_totals': [{'category': k, 'amount': str(v)} for k, v in sorted(by_category.items(), key=lambda x: -x[1])],
        'alerts': alerts,
        'method': 'rules_based',
        'disclaimer': 'Análise automatizada por regras; não constitui aconselhamento financeiro profissional.',
    }
