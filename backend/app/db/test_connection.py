from sqlalchemy import text

from app.db.database import engine


try:
    with engine.connect() as connection:
        result = connection.execute(text("SELECT 1"))
        print("Conexão com PostgreSQL realizada com sucesso!")
        print(f"Resultado do teste: {result.scalar()}")
except Exception as error:
    print("Erro ao conectar com PostgreSQL:")
    print(error)