from fastapi import FastAPI

from app.api.routes.auth import router as auth_router
from app.api.routes.onboarding import router as onboarding_router


from app.api.routes.transactions import router as transactions_router

from app.api.routes.goals import router as goals_router

from app.api.routes.dashboard import router as dashboard_router

from app.api.routes.intelligence import router as intelligence_router

app = FastAPI()

app.include_router(auth_router)
app.include_router(onboarding_router)
app.include_router(transactions_router)
app.include_router(goals_router)
app.include_router(dashboard_router)
app.include_router(intelligence_router)


@app.get("/")
def root():
    return {"message": "API do Valora funcionando"}


@app.get("/health")
def health_check():
    return {"status": "online"}