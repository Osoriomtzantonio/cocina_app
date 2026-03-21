from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

# Archivo de la base de datos SQLite (se crea automáticamente)
DATABASE_URL = "sqlite:///./cocina.db"

# check_same_thread=False es necesario para SQLite con FastAPI
engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# Clase base para los modelos SQLAlchemy
class Base(DeclarativeBase):
    pass


# Dependencia de FastAPI: abre y cierra la sesión de DB por cada request
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
