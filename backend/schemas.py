"""
schemas.py — Funciones de conversión entre ORM y formato TheMealDB

Flutter espera exactamente el mismo JSON que TheMealDB:
  Recetas:    { "meals": [ { "idMeal": "1", "strMeal": "...", ... } ] }
  Categorías: { "categories": [ { "idCategory": "1", "strCategory": "...", ... } ] }

Aquí convertimos los objetos SQLAlchemy a ese formato.
"""
from pydantic import BaseModel, EmailStr
from typing import Optional


# ══════════════════════════════════════════════════════════════
# SCHEMAS DE USUARIO Y AUTH (Pydantic — valida los datos)
# ══════════════════════════════════════════════════════════════

class UsuarioRegistro(BaseModel):
    nombre: str
    email: EmailStr
    password: str


class UsuarioLogin(BaseModel):
    email: EmailStr
    password: str


class UsuarioRespuesta(BaseModel):
    id: int
    nombre: str
    email: str

    model_config = {"from_attributes": True}


class TokenRespuesta(BaseModel):
    access_token: str
    token_type: str = "bearer"
    usuario: UsuarioRespuesta


# ══════════════════════════════════════════════════════════════
# SCHEMAS DE RECETA (Pydantic — para crear/actualizar)
# Usamos los nombres de TheMealDB para no cambiar nada en Flutter
# ══════════════════════════════════════════════════════════════

class RecetaCrear(BaseModel):
    strMeal:         str
    strCategory:     str
    strArea:         str = ""
    strInstructions: str = ""
    strMealThumb:    str = ""
    # Ingredientes (hasta 20)
    strIngredient1:  Optional[str] = ""
    strMeasure1:     Optional[str] = ""
    strIngredient2:  Optional[str] = ""
    strMeasure2:     Optional[str] = ""
    strIngredient3:  Optional[str] = ""
    strMeasure3:     Optional[str] = ""
    strIngredient4:  Optional[str] = ""
    strMeasure4:     Optional[str] = ""
    strIngredient5:  Optional[str] = ""
    strMeasure5:     Optional[str] = ""
    strIngredient6:  Optional[str] = ""
    strMeasure6:     Optional[str] = ""
    strIngredient7:  Optional[str] = ""
    strMeasure7:     Optional[str] = ""
    strIngredient8:  Optional[str] = ""
    strMeasure8:     Optional[str] = ""
    strIngredient9:  Optional[str] = ""
    strMeasure9:     Optional[str] = ""
    strIngredient10: Optional[str] = ""
    strMeasure10:    Optional[str] = ""
    strIngredient11: Optional[str] = ""
    strMeasure11:    Optional[str] = ""
    strIngredient12: Optional[str] = ""
    strMeasure12:    Optional[str] = ""
    strIngredient13: Optional[str] = ""
    strMeasure13:    Optional[str] = ""
    strIngredient14: Optional[str] = ""
    strMeasure14:    Optional[str] = ""
    strIngredient15: Optional[str] = ""
    strMeasure15:    Optional[str] = ""
    strIngredient16: Optional[str] = ""
    strMeasure16:    Optional[str] = ""
    strIngredient17: Optional[str] = ""
    strMeasure17:    Optional[str] = ""
    strIngredient18: Optional[str] = ""
    strMeasure18:    Optional[str] = ""
    strIngredient19: Optional[str] = ""
    strMeasure19:    Optional[str] = ""
    strIngredient20: Optional[str] = ""
    strMeasure20:    Optional[str] = ""


class CategoriaCrear(BaseModel):
    strCategory:            str
    strCategoryThumb:       str = ""
    strCategoryDescription: str = ""


# ══════════════════════════════════════════════════════════════
# FUNCIONES DE CONVERSIÓN ORM → TheMealDB JSON
# ══════════════════════════════════════════════════════════════

def receta_a_mealdb(r) -> dict:
    """Convierte un objeto Receta (ORM) al formato completo de TheMealDB."""
    return {
        "idMeal":          str(r.id),
        "strMeal":         r.nombre,
        "strCategory":     r.categoria,
        "strArea":         r.area          or "",
        "strInstructions": r.instrucciones or "",
        "strMealThumb":    r.imagen_url    or "",
        "strIngredient1":  r.ingrediente1  or "",  "strMeasure1":  r.medida1  or "",
        "strIngredient2":  r.ingrediente2  or "",  "strMeasure2":  r.medida2  or "",
        "strIngredient3":  r.ingrediente3  or "",  "strMeasure3":  r.medida3  or "",
        "strIngredient4":  r.ingrediente4  or "",  "strMeasure4":  r.medida4  or "",
        "strIngredient5":  r.ingrediente5  or "",  "strMeasure5":  r.medida5  or "",
        "strIngredient6":  r.ingrediente6  or "",  "strMeasure6":  r.medida6  or "",
        "strIngredient7":  r.ingrediente7  or "",  "strMeasure7":  r.medida7  or "",
        "strIngredient8":  r.ingrediente8  or "",  "strMeasure8":  r.medida8  or "",
        "strIngredient9":  r.ingrediente9  or "",  "strMeasure9":  r.medida9  or "",
        "strIngredient10": r.ingrediente10 or "", "strMeasure10": r.medida10 or "",
        "strIngredient11": r.ingrediente11 or "", "strMeasure11": r.medida11 or "",
        "strIngredient12": r.ingrediente12 or "", "strMeasure12": r.medida12 or "",
        "strIngredient13": r.ingrediente13 or "", "strMeasure13": r.medida13 or "",
        "strIngredient14": r.ingrediente14 or "", "strMeasure14": r.medida14 or "",
        "strIngredient15": r.ingrediente15 or "", "strMeasure15": r.medida15 or "",
        "strIngredient16": r.ingrediente16 or "", "strMeasure16": r.medida16 or "",
        "strIngredient17": r.ingrediente17 or "", "strMeasure17": r.medida17 or "",
        "strIngredient18": r.ingrediente18 or "", "strMeasure18": r.medida18 or "",
        "strIngredient19": r.ingrediente19 or "", "strMeasure19": r.medida19 or "",
        "strIngredient20": r.ingrediente20 or "", "strMeasure20": r.medida20 or "",
    }


def receta_a_mealdb_simple(r) -> dict:
    """Versión simplificada (solo id, nombre, imagen) — como el endpoint filter.php."""
    return {
        "idMeal":       str(r.id),
        "strMeal":      r.nombre,
        "strMealThumb": r.imagen_url or "",
    }


def categoria_a_mealdb(c) -> dict:
    """Convierte un objeto Categoria (ORM) al formato de TheMealDB."""
    return {
        "idCategory":             str(c.id),
        "strCategory":            c.nombre,
        "strCategoryThumb":       c.imagen_url  or "",
        "strCategoryDescription": c.descripcion or "",
    }


def schema_a_orm_receta(data: RecetaCrear) -> dict:
    """Convierte RecetaCrear (Pydantic) a campos del modelo ORM Receta."""
    return {
        "nombre":        data.strMeal,
        "categoria":     data.strCategory,
        "area":          data.strArea,
        "instrucciones": data.strInstructions,
        "imagen_url":    data.strMealThumb,
        "ingrediente1":  data.strIngredient1  or "", "medida1":  data.strMeasure1  or "",
        "ingrediente2":  data.strIngredient2  or "", "medida2":  data.strMeasure2  or "",
        "ingrediente3":  data.strIngredient3  or "", "medida3":  data.strMeasure3  or "",
        "ingrediente4":  data.strIngredient4  or "", "medida4":  data.strMeasure4  or "",
        "ingrediente5":  data.strIngredient5  or "", "medida5":  data.strMeasure5  or "",
        "ingrediente6":  data.strIngredient6  or "", "medida6":  data.strMeasure6  or "",
        "ingrediente7":  data.strIngredient7  or "", "medida7":  data.strMeasure7  or "",
        "ingrediente8":  data.strIngredient8  or "", "medida8":  data.strMeasure8  or "",
        "ingrediente9":  data.strIngredient9  or "", "medida9":  data.strMeasure9  or "",
        "ingrediente10": data.strIngredient10 or "", "medida10": data.strMeasure10 or "",
        "ingrediente11": data.strIngredient11 or "", "medida11": data.strMeasure11 or "",
        "ingrediente12": data.strIngredient12 or "", "medida12": data.strMeasure12 or "",
        "ingrediente13": data.strIngredient13 or "", "medida13": data.strMeasure13 or "",
        "ingrediente14": data.strIngredient14 or "", "medida14": data.strMeasure14 or "",
        "ingrediente15": data.strIngredient15 or "", "medida15": data.strMeasure15 or "",
        "ingrediente16": data.strIngredient16 or "", "medida16": data.strMeasure16 or "",
        "ingrediente17": data.strIngredient17 or "", "medida17": data.strMeasure17 or "",
        "ingrediente18": data.strIngredient18 or "", "medida18": data.strMeasure18 or "",
        "ingrediente19": data.strIngredient19 or "", "medida19": data.strMeasure19 or "",
        "ingrediente20": data.strIngredient20 or "", "medida20": data.strMeasure20 or "",
    }
