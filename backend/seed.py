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
        imagen_url    = "",
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
        imagen_url    = "",
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
        imagen_url    = "",
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
        imagen_url    = "",
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
        imagen_url    = "",
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
        imagen_url    = "",
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

    # ── POLLO ─────────────────────────────────────────────────────────
    models.Receta(
        nombre        = "Pollo en Mole",
        categoria     = "Pollo",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Cocer el pollo con cebolla, ajo y sal hasta que esté tierno.\n"
            "Tostar los chiles mulato, ancho y pasilla en el comal.\n"
            "Licuar los chiles con jitomate, ajo, cebolla, chocolate, almendras y especias.\n"
            "Freír la salsa en aceite caliente por 10 minutos moviendo constantemente.\n"
            "Agregar caldo de pollo y cocinar a fuego bajo por 30 minutos.\n"
            "Incorporar el pollo cocido y dejar hervir 10 minutos más.\n"
            "Servir con arroz blanco y tortillas de maíz."
        ),
        ingrediente1="Pollo",          medida1="1 pieza entera",
        ingrediente2="Chile mulato",   medida2="3 piezas",
        ingrediente3="Chile ancho",    medida3="3 piezas",
        ingrediente4="Chile pasilla",  medida4="2 piezas",
        ingrediente5="Chocolate",      medida5="50 g",
        ingrediente6="Jitomate",       medida6="2 piezas",
        ingrediente7="Almendras",      medida7="50 g",
        ingrediente8="Ajonjolí",       medida8="2 cucharadas",
        ingrediente9="Canela",         medida9="1 raja",
        ingrediente10="Tortillas",     medida10="al gusto",
    ),
    models.Receta(
        nombre        = "Caldo de Pollo",
        categoria     = "Pollo",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Colocar el pollo en una olla con agua fría y llevar a ebullición.\n"
            "Retirar la espuma que sube a la superficie.\n"
            "Agregar cebolla, ajo, zanahoria, apio y sal.\n"
            "Cocinar a fuego medio por 45 minutos.\n"
            "Añadir calabacita, elote y chile en rama.\n"
            "Cocinar 15 minutos más hasta que las verduras estén suaves.\n"
            "Servir caliente con limón, chile y cilantro al gusto."
        ),
        ingrediente1="Pollo",          medida1="1 kg (piezas)",
        ingrediente2="Zanahoria",      medida2="2 piezas",
        ingrediente3="Calabacita",     medida3="2 piezas",
        ingrediente4="Elote",          medida4="1 pieza",
        ingrediente5="Cebolla",        medida5="1/2 pieza",
        ingrediente6="Ajo",            medida6="3 dientes",
        ingrediente7="Apio",           medida7="2 ramas",
        ingrediente8="Chile en rama",  medida8="1 pieza",
        ingrediente9="Cilantro",       medida9="al gusto",
        ingrediente10="Limón",         medida10="al gusto",
    ),

    # ── RES ───────────────────────────────────────────────────────────
    models.Receta(
        nombre        = "Birria de Res",
        categoria     = "Res",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Remojar los chiles guajillo, ancho y de árbol en agua caliente por 20 minutos.\n"
            "Licuar los chiles con ajo, cebolla, jitomate, comino, orégano y vinagre.\n"
            "Marinar la carne con la salsa y dejar reposar 2 horas en el refrigerador.\n"
            "Cocinar tapado en olla a presión por 1 hora o en horno a 160°C por 3 horas.\n"
            "Deshebre la carne y reservar el consomé.\n"
            "Servir en tacos con cebolla, cilantro y limón, acompañados del consomé."
        ),
        ingrediente1="Carne de res",   medida1="1 kg (chambarete)",
        ingrediente2="Chile guajillo", medida2="6 piezas",
        ingrediente3="Chile ancho",    medida3="3 piezas",
        ingrediente4="Chile de árbol", medida4="2 piezas",
        ingrediente5="Ajo",            medida5="4 dientes",
        ingrediente6="Cebolla",        medida6="1 pieza",
        ingrediente7="Jitomate",       medida7="2 piezas",
        ingrediente8="Comino",         medida8="1 cucharadita",
        ingrediente9="Orégano",        medida9="1 cucharada",
        ingrediente10="Tortillas",     medida10="al gusto",
    ),
    models.Receta(
        nombre        = "Carne Asada",
        categoria     = "Res",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Marinar la carne con jugo de limón, ajo, sal, pimienta y comino por 1 hora.\n"
            "Calentar el asador o sartén a fuego muy alto.\n"
            "Asar la carne 4-5 minutos por cada lado según el término deseado.\n"
            "Dejar reposar la carne 5 minutos antes de cortar.\n"
            "Cortar en tiras y servir con guacamole, pico de gallo y tortillas."
        ),
        ingrediente1="Arrachera",      medida1="1 kg",
        ingrediente2="Limón",          medida2="4 piezas",
        ingrediente3="Ajo",            medida3="4 dientes",
        ingrediente4="Comino",         medida4="1 cucharadita",
        ingrediente5="Sal",            medida5="al gusto",
        ingrediente6="Pimienta",       medida6="al gusto",
        ingrediente7="Cebolla",        medida7="1 pieza",
        ingrediente8="Chile de árbol", medida8="2 piezas",
        ingrediente9="Cilantro",       medida9="al gusto",
        ingrediente10="Tortillas",     medida10="al gusto",
    ),
    models.Receta(
        nombre        = "Milanesa de Res",
        categoria     = "Res",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Aplanar las filetes de res con un mazo de cocina.\n"
            "Sazonar con sal, pimienta y ajo en polvo.\n"
            "Pasar cada filete por harina, luego por huevo batido y finalmente por pan molido.\n"
            "Freír en aceite caliente hasta que estén doradas y crujientes.\n"
            "Escurrir en papel absorbente.\n"
            "Servir con ensalada, arroz y frijoles."
        ),
        ingrediente1="Filete de res",  medida1="4 piezas",
        ingrediente2="Pan molido",     medida2="1 taza",
        ingrediente3="Harina",         medida3="1/2 taza",
        ingrediente4="Huevo",          medida4="2 piezas",
        ingrediente5="Ajo en polvo",   medida5="1 cucharadita",
        ingrediente6="Sal",            medida6="al gusto",
        ingrediente7="Pimienta",       medida7="al gusto",
        ingrediente8="Aceite",         medida8="para freír",
        ingrediente9="Limón",          medida9="al gusto",
    ),

    # ── VEGETARIANO ───────────────────────────────────────────────────
    models.Receta(
        nombre        = "Chiles Rellenos",
        categoria     = "Vegetariano",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Asar los chiles poblanos directamente en la flama hasta que la piel se queme.\n"
            "Envolver en plástico por 10 minutos y pelar.\n"
            "Hacer una incisión y retirar las semillas con cuidado.\n"
            "Rellenar con queso Oaxaca o panela.\n"
            "Pasar por harina y luego por clara de huevo batida a punto de turrón.\n"
            "Freír en aceite caliente hasta que el capeado esté dorado.\n"
            "Servir con salsa de jitomate caliente."
        ),
        ingrediente1="Chile poblano",  medida1="4 piezas",
        ingrediente2="Queso Oaxaca",   medida2="300 g",
        ingrediente3="Huevo",          medida3="3 piezas",
        ingrediente4="Harina",         medida4="4 cucharadas",
        ingrediente5="Jitomate",       medida5="3 piezas",
        ingrediente6="Cebolla",        medida6="1/2 pieza",
        ingrediente7="Ajo",            medida7="2 dientes",
        ingrediente8="Aceite",         medida8="para freír",
        ingrediente9="Sal",            medida9="al gusto",
    ),
    models.Receta(
        nombre        = "Enfrijoladas",
        categoria     = "Vegetariano",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Licuar los frijoles cocidos con ajo, cebolla y chile chipotle.\n"
            "Calentar la salsa de frijol en una sartén con un poco de aceite.\n"
            "Pasar las tortillas por la salsa caliente.\n"
            "Doblar las tortillas en cuatro o enrollar.\n"
            "Bañar con más salsa y decorar con crema, queso y cebolla morada.\n"
            "Servir de inmediato acompañadas de aguacate."
        ),
        ingrediente1="Frijoles negros", medida1="2 tazas cocidos",
        ingrediente2="Tortillas",       medida2="8 piezas",
        ingrediente3="Chile chipotle",  medida3="1 pieza",
        ingrediente4="Ajo",             medida4="1 diente",
        ingrediente5="Cebolla",         medida5="1/4 pieza",
        ingrediente6="Crema",           medida6="4 cucharadas",
        ingrediente7="Queso fresco",    medida7="100 g",
        ingrediente8="Aguacate",        medida8="1 pieza",
        ingrediente9="Aceite",          medida9="2 cucharadas",
    ),

    # ── MARISCOS ──────────────────────────────────────────────────────
    models.Receta(
        nombre        = "Camarones a la Diabla",
        categoria     = "Mariscos",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Limpiar y desvenar los camarones, dejar con cola.\n"
            "Licuar chiles de árbol, guajillo, jitomate, ajo y cebolla.\n"
            "Saltear los camarones en mantequilla con ajo por 2 minutos.\n"
            "Agregar la salsa de chile y cocinar 5 minutos a fuego medio.\n"
            "Sazonar con sal y pimienta al gusto.\n"
            "Servir sobre arroz blanco con tortillas calientes."
        ),
        ingrediente1="Camarones",      medida1="500 g",
        ingrediente2="Chile de árbol", medida2="5 piezas",
        ingrediente3="Chile guajillo", medida3="3 piezas",
        ingrediente4="Jitomate",       medida4="2 piezas",
        ingrediente5="Ajo",            medida5="3 dientes",
        ingrediente6="Cebolla",        medida6="1/2 pieza",
        ingrediente7="Mantequilla",    medida7="3 cucharadas",
        ingrediente8="Sal",            medida8="al gusto",
        ingrediente9="Arroz",          medida9="al gusto",
    ),
    models.Receta(
        nombre        = "Aguachile de Camarón",
        categoria     = "Mariscos",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Limpiar los camarones y abrirlos en mariposa.\n"
            "Licuar el jugo de limón con chile serrano, cilantro y sal.\n"
            "Marinar los camarones en el aguachile por 10 minutos en el refrigerador.\n"
            "Los camarones se 'cocerán' con el ácido del limón.\n"
            "Servir sobre pepino rebanado y cebolla morada.\n"
            "Decorar con aguacate y totopos."
        ),
        ingrediente1="Camarón crudo",  medida1="400 g",
        ingrediente2="Limón",          medida2="8 piezas",
        ingrediente3="Chile serrano",  medida3="2 piezas",
        ingrediente4="Cilantro",       medida4="1/2 manojo",
        ingrediente5="Pepino",         medida5="1 pieza",
        ingrediente6="Cebolla morada", medida6="1/2 pieza",
        ingrediente7="Aguacate",       medida7="1 pieza",
        ingrediente8="Sal",            medida8="al gusto",
        ingrediente9="Totopos",        medida9="al gusto",
    ),

    # ── SOPAS ─────────────────────────────────────────────────────────
    models.Receta(
        nombre        = "Sopa de Lima",
        categoria     = "Sopas",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Cocer el pollo en caldo con cebolla, ajo y sal.\n"
            "Retirar el pollo, deshebrarlo y reservar el caldo.\n"
            "Sofreír jitomate, cebolla y chile dulce en aceite.\n"
            "Agregar el caldo y llevar a hervor.\n"
            "Exprimir las limas al caldo y agregar el jugo.\n"
            "Servir con pollo deshebrado, tiras de tortilla frita y chile habanero al gusto."
        ),
        ingrediente1="Pollo",          medida1="500 g",
        ingrediente2="Lima",           medida2="4 piezas",
        ingrediente3="Jitomate",       medida3="2 piezas",
        ingrediente4="Cebolla",        medida4="1 pieza",
        ingrediente5="Chile dulce",    medida5="1 pieza",
        ingrediente6="Ajo",            medida6="2 dientes",
        ingrediente7="Tortillas",      medida7="4 piezas (para freír)",
        ingrediente8="Chile habanero", medida8="al gusto",
        ingrediente9="Cilantro",       medida9="al gusto",
    ),
    models.Receta(
        nombre        = "Caldo Tlalpeño",
        categoria     = "Sopas",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Cocer el pollo y los garbanzos juntos con ajo, cebolla y sal.\n"
            "Asar el chile chipotle, jitomate y ajo en el comal.\n"
            "Licuar el chipotle con jitomate y agregar al caldo.\n"
            "Añadir epazote y dejar hervir 10 minutos.\n"
            "Servir con aguacate en cubos y limón al gusto."
        ),
        ingrediente1="Pollo",          medida1="500 g",
        ingrediente2="Garbanzo",       medida2="1 taza (cocido)",
        ingrediente3="Chile chipotle", medida3="2 piezas",
        ingrediente4="Jitomate",       medida4="2 piezas",
        ingrediente5="Epazote",        medida5="3 ramas",
        ingrediente6="Cebolla",        medida6="1/2 pieza",
        ingrediente7="Ajo",            medida7="2 dientes",
        ingrediente8="Aguacate",       medida8="1 pieza",
        ingrediente9="Limón",          medida9="al gusto",
    ),

    # ── POSTRES ───────────────────────────────────────────────────────
    models.Receta(
        nombre        = "Flan Napolitano",
        categoria     = "Postres",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Preparar el caramelo: derretir el azúcar en una sartén sin mover hasta que tome color dorado.\n"
            "Verter el caramelo en el molde y distribuir bien.\n"
            "Licuar la leche condensada, leche evaporada, huevos y queso crema.\n"
            "Verter la mezcla sobre el caramelo en el molde.\n"
            "Hornear a baño maría a 180°C por 50-60 minutos.\n"
            "Dejar enfriar completamente antes de desmoldar.\n"
            "Refrigerar mínimo 2 horas antes de servir."
        ),
        ingrediente1="Leche condensada",  medida1="1 lata (397 g)",
        ingrediente2="Leche evaporada",   medida2="1 lata (360 ml)",
        ingrediente3="Huevo",             medida3="4 piezas",
        ingrediente4="Queso crema",       medida4="190 g",
        ingrediente5="Azúcar",            medida5="1 taza (para caramelo)",
        ingrediente6="Vainilla",          medida6="1 cucharadita",
    ),
    models.Receta(
        nombre        = "Arroz con Leche",
        categoria     = "Postres",
        area          = "Mexicano",
        imagen_url    = "",
        instrucciones = (
            "Cocer el arroz en agua con canela y cáscara de limón por 15 minutos.\n"
            "Agregar la leche entera y la leche condensada.\n"
            "Cocinar a fuego bajo moviendo constantemente para evitar que se pegue.\n"
            "Cocinar hasta que el arroz esté cremoso y la leche se haya absorbido.\n"
            "Retirar del fuego y agregar la vainilla.\n"
            "Servir frío o caliente espolvoreado con canela en polvo."
        ),
        ingrediente1="Arroz",             medida1="1 taza",
        ingrediente2="Leche entera",      medida2="1 litro",
        ingrediente3="Leche condensada",  medida3="1/2 lata",
        ingrediente4="Canela",            medida4="2 rajas",
        ingrediente5="Cáscara de limón",  medida5="1 tira",
        ingrediente6="Vainilla",          medida6="1 cucharadita",
        ingrediente7="Canela en polvo",   medida7="para decorar",
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
