"""
seed.py — Datos iniciales para la base de datos

Ejecutar UNA VEZ con: python seed.py
Agrega categorías y recetas mexicanas de ejemplo.
"""
from database import SessionLocal, engine, Base
import models

Base.metadata.create_all(bind=engine)
db = SessionLocal()


# ── CATEGORÍAS ────────────────────────────────────────────────────────
categorias = [
    models.Categoria(
        nombre="Pollo",
        imagen_url="https://www.themealdb.com/images/category/chicken.png",
        descripcion="Platillos preparados con pollo",
    ),
    models.Categoria(
        nombre="Res",
        imagen_url="https://www.themealdb.com/images/category/beef.png",
        descripcion="Platillos preparados con carne de res",
    ),
    models.Categoria(
        nombre="Vegetariano",
        imagen_url="https://www.themealdb.com/images/category/vegetarian.png",
        descripcion="Platillos sin carne",
    ),
    models.Categoria(
        nombre="Mariscos",
        imagen_url="https://www.themealdb.com/images/category/seafood.png",
        descripcion="Platillos con pescado y mariscos",
    ),
    models.Categoria(
        nombre="Postres",
        imagen_url="https://www.themealdb.com/images/category/dessert.png",
        descripcion="Dulces y postres mexicanos",
    ),
    models.Categoria(
        nombre="Sopas",
        imagen_url="https://www.themealdb.com/images/category/pasta.png",
        descripcion="Caldos y sopas tradicionales",
    ),
]

for cat in categorias:
    existe = db.query(models.Categoria).filter(
        models.Categoria.nombre == cat.nombre
    ).first()
    if not existe:
        db.add(cat)

db.commit()
print("✓ Categorías creadas")


# ── RECETAS ───────────────────────────────────────────────────────────
recetas = [
    models.Receta(
        nombre        = "Tacos al Pastor",
        categoria     = "Pollo",
        area          = "Mexicano",
        imagen_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3b/Tacos_al_pastor.jpg/640px-Tacos_al_pastor.jpg",
        instrucciones = (
            "Marinar el pollo con chile guajillo, achiote, naranja y especias por 2 horas.\n"
            "Cocinar el pollo en trompo o sartén a fuego medio-alto.\n"
            "Cortar en tiras finas y servir en tortillas de maíz.\n"
            "Agregar cebolla picada, cilantro, piña y salsa al gusto."
        ),
        ingrediente1="Pollo",          medida1="1 kg",
        ingrediente2="Chile guajillo", medida2="4 piezas",
        ingrediente3="Achiote",        medida3="2 cucharadas",
        ingrediente4="Naranja",        medida4="1 pieza",
        ingrediente5="Vinagre blanco", medida5="2 cucharadas",
        ingrediente6="Ajo",            medida6="3 dientes",
        ingrediente7="Cebolla",        medida7="1 pieza",
        ingrediente8="Piña",           medida8="1/4 pieza",
        ingrediente9="Cilantro",       medida9="al gusto",
        ingrediente10="Tortillas",     medida10="12 piezas",
    ),
    models.Receta(
        nombre        = "Guacamole Tradicional",
        categoria     = "Vegetariano",
        area          = "Mexicano",
        imagen_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Guacamole.jpg/640px-Guacamole.jpg",
        instrucciones = (
            "Partir los aguacates por la mitad y retirar el hueso.\n"
            "Extraer la pulpa y machacar con un tenedor hasta obtener la textura deseada.\n"
            "Agregar el jitomate picado, cebolla, cilantro, chile y limón.\n"
            "Mezclar bien y sazonar con sal al gusto.\n"
            "Servir inmediatamente con totopos."
        ),
        ingrediente1="Aguacate",    medida1="3 piezas",
        ingrediente2="Jitomate",    medida2="1 pieza",
        ingrediente3="Cebolla",     medida3="1/4 pieza",
        ingrediente4="Cilantro",    medida4="3 ramas",
        ingrediente5="Chile serrano",medida5="1 pieza",
        ingrediente6="Limón",       medida6="2 piezas",
        ingrediente7="Sal",         medida7="al gusto",
        ingrediente8="Totopos",     medida8="al gusto",
    ),
    models.Receta(
        nombre        = "Pozole Rojo",
        categoria     = "Sopas",
        area          = "Mexicano",
        imagen_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Pozole_rojo.jpg/640px-Pozole_rojo.jpg",
        instrucciones = (
            "Cocer el maíz pozolero previamente remojado por 2 horas.\n"
            "Cocinar la carne de cerdo con ajo, cebolla y sal hasta que esté suave.\n"
            "Remojar los chiles guajillo y ancho, licuar con ajo y colar.\n"
            "Agregar el chile a la olla con el maíz y la carne.\n"
            "Hervir a fuego lento por 30 minutos.\n"
            "Servir con lechuga, orégano, cebolla, tostadas y rábano."
        ),
        ingrediente1="Maíz pozolero", medida1="500 g",
        ingrediente2="Carne de cerdo",medida2="700 g",
        ingrediente3="Chile guajillo",medida3="5 piezas",
        ingrediente4="Chile ancho",   medida4="2 piezas",
        ingrediente5="Ajo",           medida5="4 dientes",
        ingrediente6="Cebolla",       medida6="1 pieza",
        ingrediente7="Orégano",       medida7="1 cucharada",
        ingrediente8="Lechuga",       medida8="al gusto",
        ingrediente9="Rábano",        medida9="al gusto",
        ingrediente10="Tostadas",     medida10="al gusto",
    ),
    models.Receta(
        nombre        = "Enchiladas Rojas",
        categoria     = "Pollo",
        area          = "Mexicano",
        imagen_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Enchiladas_rojas.jpg/640px-Enchiladas_rojas.jpg",
        instrucciones = (
            "Remojar los chiles guajillo y mulato, quitar semillas y licuar con ajo.\n"
            "Freír la salsa en aceite caliente por 5 minutos.\n"
            "Pasar las tortillas por la salsa y rellenar con pollo deshebrado.\n"
            "Doblar o enrollar y colocar en un refractario.\n"
            "Bañar con más salsa y hornear a 180°C por 15 minutos.\n"
            "Servir con crema, queso y cebolla morada."
        ),
        ingrediente1="Tortillas",      medida1="12 piezas",
        ingrediente2="Pollo cocido",   medida2="400 g",
        ingrediente3="Chile guajillo", medida3="6 piezas",
        ingrediente4="Chile mulato",   medida4="2 piezas",
        ingrediente5="Ajo",            medida5="2 dientes",
        ingrediente6="Crema",          medida6="1/2 taza",
        ingrediente7="Queso fresco",   medida7="150 g",
        ingrediente8="Cebolla morada", medida8="1/2 pieza",
        ingrediente9="Aceite",         medida9="3 cucharadas",
    ),
    models.Receta(
        nombre        = "Caldo de Camarón",
        categoria     = "Mariscos",
        area          = "Mexicano",
        imagen_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/Caldo_de_camaron.jpg/640px-Caldo_de_camaron.jpg",
        instrucciones = (
            "Hervir los camarones con cebolla y ajo para hacer el caldo base.\n"
            "Licuar jitomate, chile guajillo, cebolla y ajo.\n"
            "Freír la salsa en aceite hasta que oscurezca.\n"
            "Agregar el caldo de camarón y dejar hervir.\n"
            "Añadir papa, zanahoria y los camarones.\n"
            "Cocinar hasta que las verduras estén suaves."
        ),
        ingrediente1="Camarones",      medida1="500 g",
        ingrediente2="Papa",           medida2="2 piezas",
        ingrediente3="Zanahoria",      medida3="2 piezas",
        ingrediente4="Chile guajillo", medida4="3 piezas",
        ingrediente5="Jitomate",       medida5="2 piezas",
        ingrediente6="Cebolla",        medida6="1 pieza",
        ingrediente7="Ajo",            medida7="3 dientes",
        ingrediente8="Cilantro",       medida8="al gusto",
        ingrediente9="Limón",          medida9="al gusto",
    ),
    models.Receta(
        nombre        = "Churros con Chocolate",
        categoria     = "Postres",
        area          = "Mexicano",
        imagen_url    = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Churros_con_chocolate.jpg/640px-Churros_con_chocolate.jpg",
        instrucciones = (
            "Hervir el agua con sal y mantequilla.\n"
            "Agregar la harina de golpe y revolver hasta formar una masa.\n"
            "Meter la masa en una manga con duya estrellada.\n"
            "Freír en aceite caliente hasta que estén dorados.\n"
            "Escurrir y revolcar en azúcar con canela.\n"
            "Preparar la salsa de chocolate caliente y servir para dippear."
        ),
        ingrediente1="Harina",        medida1="1 taza",
        ingrediente2="Agua",          medida2="1 taza",
        ingrediente3="Mantequilla",   medida3="2 cucharadas",
        ingrediente4="Sal",           medida4="1 pizca",
        ingrediente5="Aceite",        medida5="para freír",
        ingrediente6="Azúcar",        medida6="1/2 taza",
        ingrediente7="Canela",        medida7="1 cucharada",
        ingrediente8="Chocolate",     medida8="200 g",
        ingrediente9="Leche",         medida9="1/2 taza",
    ),
]

for receta in recetas:
    existe = db.query(models.Receta).filter(
        models.Receta.nombre == receta.nombre
    ).first()
    if not existe:
        db.add(receta)

db.commit()
db.close()
print("✓ Recetas creadas")
print("\n¡Base de datos lista! Corre el servidor con:")
print("  uvicorn main:app --reload --host 0.0.0.0 --port 8000")
