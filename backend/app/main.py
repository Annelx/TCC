from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def root():
    return {"message": "API do Valora funcionando"}


@app.get("/health")
def health_check():
    return {"status": "online"}