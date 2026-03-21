from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from database import get_db
from auth import get_current_user
import models, schemas

router = APIRouter(prefix="/favoritos", tags=["Favoritos"])


@router.get("")
def listar_favoritos(
    db: Session = Depends(get_db),
    usuario: models.Usuario = Depends(get_current_user),
):
    """
    Devuelve las recetas favoritas del usuario autenticado.
    Respuesta en formato TheMealDB: { "meals": [...] }
    """
    favoritos = db.query(models.Favorito).filter(
        models.Favorito.usuario_id == usuario.id
    ).all()

    recetas = []
    for fav in favoritos:
        receta = db.query(models.Receta).filter(
            models.Receta.id == fav.receta_id
        ).first()
        if receta:
            recetas.append(schemas.receta_a_mealdb(receta))

    return {"meals": recetas if recetas else None}


@router.post("/{id_receta}", status_code=201)
def agregar_favorito(
    id_receta: int,
    db: Session = Depends(get_db),
    usuario: models.Usuario = Depends(get_current_user),
):
    """Guarda una receta en los favoritos del usuario."""
    # Verificamos que la receta exista
    receta = db.query(models.Receta).filter(models.Receta.id == id_receta).first()
    if not receta:
        raise HTTPException(status_code=404, detail="Receta no encontrada")

    favorito = models.Favorito(usuario_id=usuario.id, receta_id=id_receta)
    db.add(favorito)

    try:
        db.commit()
    except IntegrityError:
        # Ya estaba guardada (UniqueConstraint)
        db.rollback()
        raise HTTPException(status_code=400, detail="La receta ya está en favoritos")

    return {"mensaje": "Receta guardada en favoritos"}


@router.delete("/{id_receta}", status_code=204)
def eliminar_favorito(
    id_receta: int,
    db: Session = Depends(get_db),
    usuario: models.Usuario = Depends(get_current_user),
):
    """Elimina una receta de los favoritos del usuario."""
    favorito = db.query(models.Favorito).filter(
        models.Favorito.usuario_id == usuario.id,
        models.Favorito.receta_id  == id_receta,
    ).first()

    if not favorito:
        raise HTTPException(status_code=404, detail="No está en favoritos")

    db.delete(favorito)
    db.commit()


@router.get("/verificar/{id_receta}")
def verificar_favorito(
    id_receta: int,
    db: Session = Depends(get_db),
    usuario: models.Usuario = Depends(get_current_user),
):
    """Verifica si una receta ya está en los favoritos del usuario."""
    existe = db.query(models.Favorito).filter(
        models.Favorito.usuario_id == usuario.id,
        models.Favorito.receta_id  == id_receta,
    ).first() is not None

    return {"esFavorita": existe}
