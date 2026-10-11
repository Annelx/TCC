from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.models.transaction import Transaction
from app.schemas.transaction import TransactionInput, TransactionOutput

router = APIRouter(prefix="/transactions", tags=["Transacoes"])
CATEGORIES = ["Moradia", "Alimentação", "Transporte", "Saúde", "Educação", "Lazer", "Salário", "Outros"]

@router.get("/categories")
def categories(user: User = Depends(get_current_user)):
    return {"categories": CATEGORIES}

@router.get("", response_model=list[TransactionOutput])
def list_transactions(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return db.scalars(select(Transaction).where(Transaction.user_id == user.id).order_by(Transaction.occurred_at.desc(), Transaction.id.desc())).all()

@router.post("", response_model=TransactionOutput, status_code=201)
def create_transaction(data: TransactionInput, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    transaction = Transaction(user_id=user.id, **data.model_dump())
    db.add(transaction)
    db.commit()
    db.refresh(transaction)
    return transaction

def own_transaction(transaction_id: int, user: User, db: Session) -> Transaction:
    transaction = db.scalar(select(Transaction).where(Transaction.id == transaction_id, Transaction.user_id == user.id))
    if transaction is None:
        raise HTTPException(404, "Transação não encontrada")
    return transaction

@router.put("/{transaction_id}", response_model=TransactionOutput)
def update_transaction(transaction_id: int, data: TransactionInput, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    transaction = own_transaction(transaction_id, user, db)
    for key, value in data.model_dump().items():
        setattr(transaction, key, value)
    db.commit()
    db.refresh(transaction)
    return transaction

@router.delete("/{transaction_id}", status_code=204)
def delete_transaction(transaction_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    transaction = own_transaction(transaction_id, user, db)
    db.delete(transaction)
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
