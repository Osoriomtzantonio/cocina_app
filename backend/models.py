from sqlalchemy import Column, Integer, String, Text, ForeignKey, UniqueConstraint
from database import Base


# ══════════════════════════════════════════════════════════════
# MODELOS SQLAlchemy — definen las tablas de la base de datos
# Cada clase = una tabla, cada atributo Column = una columna
# ══════════════════════════════════════════════════════════════

class Usuario(Base):
    __tablename__ = "usuarios"

    id               = Column(Integer, primary_key=True, index=True)
    nombre           = Column(String(100), nullable=False)
    email            = Column(String(200), unique=True, nullable=False, index=True)
    hashed_password  = Column(String(200), nullable=False)


class Categoria(Base):
    __tablename__ = "categorias"

    id          = Column(Integer, primary_key=True, index=True)
    nombre      = Column(String(100), unique=True, nullable=False)
    imagen_url  = Column(String(500), default="")
    descripcion = Column(Text, default="")


class Receta(Base):
    __tablename__ = "recetas"

    id            = Column(Integer, primary_key=True, index=True)
    nombre        = Column(String(200), nullable=False)
    categoria     = Column(String(100), nullable=False)
    area          = Column(String(100), default="")
    instrucciones = Column(Text, default="")
    imagen_url    = Column(String(500), default="")

    # Ingredientes y medidas — mismo esquema que TheMealDB (hasta 20)
    ingrediente1  = Column(String(150), default="")
    medida1       = Column(String(100), default="")
    ingrediente2  = Column(String(150), default="")
    medida2       = Column(String(100), default="")
    ingrediente3  = Column(String(150), default="")
    medida3       = Column(String(100), default="")
    ingrediente4  = Column(String(150), default="")
    medida4       = Column(String(100), default="")
    ingrediente5  = Column(String(150), default="")
    medida5       = Column(String(100), default="")
    ingrediente6  = Column(String(150), default="")
    medida6       = Column(String(100), default="")
    ingrediente7  = Column(String(150), default="")
    medida7       = Column(String(100), default="")
    ingrediente8  = Column(String(150), default="")
    medida8       = Column(String(100), default="")
    ingrediente9  = Column(String(150), default="")
    medida9       = Column(String(100), default="")
    ingrediente10 = Column(String(150), default="")
    medida10      = Column(String(100), default="")
    ingrediente11 = Column(String(150), default="")
    medida11      = Column(String(100), default="")
    ingrediente12 = Column(String(150), default="")
    medida12      = Column(String(100), default="")
    ingrediente13 = Column(String(150), default="")
    medida13      = Column(String(100), default="")
    ingrediente14 = Column(String(150), default="")
    medida14      = Column(String(100), default="")
    ingrediente15 = Column(String(150), default="")
    medida15      = Column(String(100), default="")
    ingrediente16 = Column(String(150), default="")
    medida16      = Column(String(100), default="")
    ingrediente17 = Column(String(150), default="")
    medida17      = Column(String(100), default="")
    ingrediente18 = Column(String(150), default="")
    medida18      = Column(String(100), default="")
    ingrediente19 = Column(String(150), default="")
    medida19      = Column(String(100), default="")
    ingrediente20 = Column(String(150), default="")
    medida20      = Column(String(100), default="")


class Favorito(Base):
    __tablename__ = "favoritos"

    id          = Column(Integer, primary_key=True, index=True)
    usuario_id  = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False)
    receta_id   = Column(Integer, ForeignKey("recetas.id",  ondelete="CASCADE"), nullable=False)

    # Un usuario no puede guardar la misma receta dos veces
    __table_args__ = (UniqueConstraint("usuario_id", "receta_id"),)
