from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from database import get_db
import models

# ══════════════════════════════════════════════════════════════
# CONFIGURACIÓN JWT
# ══════════════════════════════════════════════════════════════

# En producción usar una variable de entorno, nunca hardcodear
SECRET_KEY  = "cocina-app-secret-key-cesun-2024"
ALGORITHM   = "HS256"
EXPIRACION  = 60 * 24 * 7  # 7 días en minutos

# Contexto para hashear contraseñas con bcrypt
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Esquema de seguridad: espera el header "Authorization: Bearer <token>"
security = HTTPBearer()


# ── CONTRASEÑAS ───────────────────────────────────────────────────────

def hashear_password(password: str) -> str:
    """Convierte la contraseña en texto plano a un hash seguro."""
    return pwd_context.hash(password)


def verificar_password(password: str, hashed: str) -> bool:
    """Compara la contraseña con su hash almacenado."""
    return pwd_context.verify(password, hashed)


# ── JWT ───────────────────────────────────────────────────────────────

def crear_token(user_id: int, email: str) -> str:
    """Crea un JWT con el ID y email del usuario."""
    expira = datetime.now(timezone.utc) + timedelta(minutes=EXPIRACION)
    payload = {
        "user_id": user_id,
        "email":   email,
        "exp":     expira,
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def verificar_token(token: str) -> dict | None:
    """Decodifica y valida el JWT. Devuelve el payload o None si es inválido."""
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    except JWTError:
        return None


# ── DEPENDENCIA: USUARIO AUTENTICADO ─────────────────────────────────
# Se usa en los endpoints protegidos con: usuario = Depends(get_current_user)

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> models.Usuario:
    """
    Dependencia de FastAPI que:
    1. Extrae el token del header Authorization
    2. Lo valida
    3. Devuelve el objeto Usuario si es válido
    4. Lanza 401 si no es válido
    """
    token   = credentials.credentials
    payload = verificar_token(token)

    if not payload:
        raise HTTPException(status_code=401, detail="Token inválido o expirado")

    usuario = db.query(models.Usuario).filter(
        models.Usuario.id == payload.get("user_id")
    ).first()

    if not usuario:
        raise HTTPException(status_code=401, detail="Usuario no encontrado")

    return usuario
