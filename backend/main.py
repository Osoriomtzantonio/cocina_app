from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine, Base
from routers import auth, recetas, categorias, favoritos

# Crea las tablas en SQLite si no existen
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="CocinaApp API",
    description="Backend de la app de recetas — CESUN Universidad",
    version="1.0.0",
)

# ── CORS ──────────────────────────────────────────────────────────────
# Permite que Flutter (emulador/celular) se conecte al servidor local
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # En producción, limitar al dominio de la app
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── ROUTERS ───────────────────────────────────────────────────────────
app.include_router(auth.router)
app.include_router(recetas.router)
app.include_router(categorias.router)
app.include_router(favoritos.router)


@app.get("/")
def raiz():
    return {"mensaje": "CocinaApp API funcionando 🍳"}
