from fastapi import FastAPI

from app.api.routes.auth import router as auth_router


app = FastAPI()

app.include_router(auth_router)


@app.get("/")
def root():
    return {"message": "API do Valora funcionando"}


@app.get("/health")
def health_check():
    return {"status": "online"}