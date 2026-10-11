from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.api.dependencies import get_current_user
from app.db.database import get_db
from app.models.user import User
from app.models.goal import Goal
from app.schemas.goal import GoalInput, GoalOutput

router = APIRouter(prefix="/goals", tags=["Metas"])

@router.get("", response_model=list[GoalOutput])
def list_goals(user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return db.scalars(select(Goal).where(Goal.user_id == user.id).order_by(Goal.deadline, Goal.id)).all()

@router.post("", response_model=GoalOutput, status_code=201)
def create_goal(data: GoalInput, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    goal = Goal(user_id=user.id, **data.model_dump())
    db.add(goal)
    db.commit()
    db.refresh(goal)
    return goal

def own_goal(goal_id: int, user: User, db: Session):
    goal = db.scalar(select(Goal).where(Goal.id == goal_id, Goal.user_id == user.id))
    if goal is None:
        raise HTTPException(404, "Meta não encontrada")
    return goal

@router.put("/{goal_id}", response_model=GoalOutput)
def update_goal(goal_id: int, data: GoalInput, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    goal = own_goal(goal_id, user, db)
    for key, value in data.model_dump().items():
        setattr(goal, key, value)
    db.commit()
    db.refresh(goal)
    return goal

@router.delete("/{goal_id}", status_code=204)
def delete_goal(goal_id: int, user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    db.delete(own_goal(goal_id, user, db))
    db.commit()
    return Response(status_code=status.HTTP_204_NO_CONTENT)
