import random
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from database import get_db
from auth import get_current_user
import models, schemas

router = APIRouter(prefix="/recetas", tags=["Recetas"])


# ── ENDPOINTS PÚBLICOS (sin login) ────────────────────────────────────

@router.get("")
def listar_recetas(limite: int = Query(20, ge=1, le=100), db: Session = Depends(get_db)):
    """Devuelve todas las recetas (con límite opcional, default 20)."""
    recetas = db.query(models.Receta).limit(limite).all()
    if not recetas:
        return {"meals": None}
    return {"meals": [schemas.receta_a_mealdb(r) for r in recetas]}


@router.get("/aleatoria")
def receta_aleatoria(db: Session = Depends(get_db)):
    """
    Devuelve una receta al azar.
    Equivalente a TheMealDB: /random.php
    """
    total = db.query(models.Receta).count()
    if total == 0:
        return {"meals": None}

    offset = random.randint(0, total - 1)
    receta = db.query(models.Receta).offset(offset).first()
    return {"meals": [schemas.receta_a_mealdb(receta)]}


@router.get("/buscar")
def buscar_recetas(s: str = Query(""), db: Session = Depends(get_db)):
    """
    Busca recetas por nombre (búsqueda parcial, sin distinguir mayúsculas).
    Equivalente a TheMealDB: /search.php?s=chicken
    """
    if not s.strip():
        return {"meals": None}

    resultados = db.query(models.Receta).filter(
        models.Receta.nombre.ilike(f"%{s}%")
    ).all()

    if not resultados:
        return {"meals": None}

    return {"meals": [schemas.receta_a_mealdb(r) for r in resultados]}


@router.get("/categoria/{categoria}")
def recetas_por_categoria(categoria: str, db: Session = Depends(get_db)):
    """
    Devuelve recetas de una categoría (datos simplificados).
    Equivalente a TheMealDB: /filter.php?c=Chicken
    """
    resultados = db.query(models.Receta).filter(
        models.Receta.categoria.ilike(categoria)
    ).all()

    if not resultados:
        return {"meals": None}

    # Datos simplificados: solo id, nombre e imagen (igual que filter.php)
    return {"meals": [schemas.receta_a_mealdb_simple(r) for r in resultados]}


@router.get("/{id_receta}")
def detalle_receta(id_receta: int, db: Session = Depends(get_db)):
    """
    Devuelve el detalle completo de una receta por ID.
    Equivalente a TheMealDB: /lookup.php?i=52772
    """
    receta = db.query(models.Receta).filter(models.Receta.id == id_receta).first()
    if not receta:
        return {"meals": None}

    return {"meals": [schemas.receta_a_mealdb(receta)]}


# ── ENDPOINTS PROTEGIDOS (requieren JWT) ─────────────────────────────

@router.post("", status_code=201)
def crear_receta(
    datos: schemas.RecetaCrear,
    db: Session = Depends(get_db),
    _usuario = Depends(get_current_user),  # verifica que el usuario esté logueado
):
    """Crea una nueva receta (requiere estar autenticado)."""
    receta = models.Receta(**schemas.schema_a_orm_receta(datos))
    db.add(receta)
    db.commit()
    db.refresh(receta)
    return {"meals": [schemas.receta_a_mealdb(receta)]}


@router.put("/{id_receta}")
def actualizar_receta(
    id_receta: int,
    datos: schemas.RecetaCrear,
    db: Session = Depends(get_db),
    _usuario = Depends(get_current_user),
):
    """Actualiza una receta existente (requiere estar autenticado)."""
    receta = db.query(models.Receta).filter(models.Receta.id == id_receta).first()
    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")

    campos = schemas.schema_a_orm_receta(datos)
    for campo, valor in campos.items():
        setattr(receta, campo, valor)

    db.commit()
    db.refresh(receta)
    return {"meals": [schemas.receta_a_mealdb(receta)]}


@router.delete("/{id_receta}", status_code=204)
def eliminar_receta(
    id_receta: int,
    db: Session = Depends(get_db),
    _usuario = Depends(get_current_user),
):
    """Elimina una receta (requiere estar autenticado)."""
    receta = db.query(models.Receta).filter(models.Receta.id == id_receta).first()
    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")

    db.delete(receta)
    db.commit()
