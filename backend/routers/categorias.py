from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from auth import get_current_user
import models, schemas

router = APIRouter(prefix="/categorias", tags=["Categorías"])


@router.get("")
def listar_categorias(db: Session = Depends(get_db)):
    """
    Devuelve todas las categorías.
    Equivalente a TheMealDB: /categories.php
    """
    categorias = db.query(models.Categoria).all()
    return {"categories": [schemas.categoria_a_mealdb(c) for c in categorias]}


@router.post("", status_code=201)
def crear_categoria(
    datos: schemas.CategoriaCrear,
    db: Session = Depends(get_db),
    _usuario = Depends(get_current_user),
):
    """Crea una nueva categoría (requiere estar autenticado)."""
    if db.query(models.Categoria).filter(
        models.Categoria.nombre.ilike(datos.strCategory)
    ).first():
        raise HTTPException(status_code=400, detail="La categoría ya existe")

    categoria = models.Categoria(
        nombre      = datos.strCategory,
        imagen_url  = datos.strCategoryThumb,
        descripcion = datos.strCategoryDescription,
    )
    db.add(categoria)
    db.commit()
    db.refresh(categoria)
    return {"categories": [schemas.categoria_a_mealdb(categoria)]}


@router.put("/{id_categoria}")
def actualizar_categoria(
    id_categoria: int,
    datos: schemas.CategoriaCrear,
    db: Session = Depends(get_db),
    _usuario = Depends(get_current_user),
):
    """Actualiza una categoría (requiere estar autenticado)."""
    categoria = db.query(models.Categoria).filter(
        models.Categoria.id == id_categoria
    ).first()
    if not categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")

    categoria.nombre      = datos.strCategory
    categoria.imagen_url  = datos.strCategoryThumb
    categoria.descripcion = datos.strCategoryDescription
    db.commit()
    db.refresh(categoria)
    return {"categories": [schemas.categoria_a_mealdb(categoria)]}


@router.delete("/{id_categoria}", status_code=204)
def eliminar_categoria(
    id_categoria: int,
    db: Session = Depends(get_db),
    _usuario = Depends(get_current_user),
):
    """Elimina una categoría (requiere estar autenticado)."""
    categoria = db.query(models.Categoria).filter(
        models.Categoria.id == id_categoria
    ).first()
    if not categoria:
        raise HTTPException(status_code=404, detail="Categoría no encontrada")

    db.delete(categoria)
    db.commit()
