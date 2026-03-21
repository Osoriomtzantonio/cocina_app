from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
import models, schemas, auth as auth_utils

router = APIRouter(prefix="/auth", tags=["Autenticación"])


@router.post("/registro", response_model=schemas.TokenRespuesta, status_code=201)
def registro(datos: schemas.UsuarioRegistro, db: Session = Depends(get_db)):
    """
    Registra un nuevo usuario.
    - Verifica que el email no esté en uso
    - Hashea la contraseña antes de guardarla
    - Devuelve un JWT listo para usar
    """
    # Verificar que el email no exista
    if db.query(models.Usuario).filter(models.Usuario.email == datos.email).first():
        raise HTTPException(status_code=400, detail="El email ya está registrado")

    # Crear el usuario con la contraseña hasheada
    usuario = models.Usuario(
        nombre          = datos.nombre,
        email           = datos.email,
        hashed_password = auth_utils.hashear_password(datos.password),
    )
    db.add(usuario)
    db.commit()
    db.refresh(usuario)

    token = auth_utils.crear_token(usuario.id, usuario.email)
    return {
        "access_token": token,
        "token_type":   "bearer",
        "usuario":      usuario,
    }


@router.post("/login", response_model=schemas.TokenRespuesta)
def login(datos: schemas.UsuarioLogin, db: Session = Depends(get_db)):
    """
    Inicia sesión con email y contraseña.
    Devuelve un JWT si las credenciales son correctas.
    """
    usuario = db.query(models.Usuario).filter(
        models.Usuario.email == datos.email
    ).first()

    # Mismo error genérico para email o contraseña incorrectos (seguridad)
    if not usuario or not auth_utils.verificar_password(datos.password, usuario.hashed_password):
        raise HTTPException(status_code=401, detail="Email o contraseña incorrectos")

    token = auth_utils.crear_token(usuario.id, usuario.email)
    return {
        "access_token": token,
        "token_type":   "bearer",
        "usuario":      usuario,
    }


@router.get("/me", response_model=schemas.UsuarioRespuesta)
def perfil(usuario: models.Usuario = Depends(auth_utils.get_current_user)):
    """Devuelve los datos del usuario autenticado (requiere token)."""
    return usuario
