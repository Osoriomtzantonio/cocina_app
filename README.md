# CocinaApp — Recetario Inteligente

Proyecto final de la materia **Desarrollo de Aplicaciones Móviles**
**CESUN Universidad** | Equipo: Antonio Osorio + Juan Gallardo

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | Flutter + Dart |
| Estado | GetX (Obx, Controllers, Bindings) |
| Backend | FastAPI (Python) |
| Base de datos | SQLite (cocina.db) |
| Autenticación | JWT (python-jose + passlib/bcrypt) |

---

## Cómo levantar el proyecto

### Backend
```bash
cd cocina_backend
venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
```
- Docs automáticas: http://localhost:8000/docs
- Primera vez: correr `venv/bin/python seed.py` para poblar la BD

### Flutter (web)
```bash
flutter run -d chrome
```

---

## Arquitectura Flutter

```
lib/
├── bindings/        # Registro de controllers (GetX)
├── controllers/     # Lógica de negocio (HomeController, AuthController...)
├── datasources/     # Implementación concreta (HTTP via ApiService)
├── models/          # RecipeModel, CategoryModel
├── repositories/    # Contrato abstracto (RecetasRepository)
├── screens/         # Pantallas de la app
├── services/        # ApiService, AuthService, FavoritesService
├── theme/           # Colores, tipografía (AppTheme)
├── utils/           # ResponsiveHelper
└── widgets/         # RecipeCard, RecipeGrid, CustomDrawer
```

---

## Pantallas

| Pantalla | Descripción |
|---|---|
| HomeScreen | Receta del día, categorías con navegación, recetas populares |
| SearchScreen | Búsqueda en tiempo real con debounce |
| CategoryScreen | Recetas filtradas por categoría |
| RecipeDetailScreen | Detalle completo con ingredientes e instrucciones |
| FavoritesScreen | Favoritos (local si no logueado, servidor si logueado) |
| LoginScreen | Autenticación con JWT |
| RegisterScreen | Registro de nuevo usuario |
| ProfileScreen | Datos del usuario y cerrar sesión |
| MisRecetasScreen | CRUD de recetas (requiere sesión) |
| RecetaFormScreen | Formulario crear/editar receta |

---

## Endpoints del backend

| Método | Endpoint | Auth | Descripción |
|---|---|---|---|
| GET | `/recetas` | No | Todas las recetas |
| GET | `/recetas/aleatoria` | No | Receta al azar |
| GET | `/recetas/buscar?s=` | No | Buscar por nombre |
| GET | `/recetas/categoria/{cat}` | No | Recetas por categoría |
| GET | `/recetas/{id}` | No | Detalle de receta |
| POST | `/recetas` | JWT | Crear receta |
| PUT | `/recetas/{id}` | JWT | Editar receta |
| DELETE | `/recetas/{id}` | JWT | Eliminar receta |
| GET | `/categorias` | No | Lista de categorías |
| POST | `/auth/registro` | No | Registrar usuario |
| POST | `/auth/login` | No | Iniciar sesión |
| GET | `/favoritos` | JWT | Favoritos del usuario |
| POST | `/favoritos/{id}` | JWT | Agregar favorito |
| DELETE | `/favoritos/{id}` | JWT | Quitar favorito |

---

## Bitácora de cambios

### 2026-03-23 — Antonio
**Funcionalidades nuevas:**
- Categorías en HomeScreen ahora son navegables (click → CategoryScreen) con animación de escala
- Barra de búsqueda en HomeScreen conectada a la tab de Buscar
- **Perfil de usuario** (`ProfileScreen`): muestra nombre, correo y botón cerrar sesión
- **CRUD de recetas** (`MisRecetasScreen` + `RecetaFormScreen`): crear, editar y eliminar recetas desde la app (requiere login)
- Drawer actualizado: muestra "Mi perfil" y "Mis recetas" cuando el usuario está logueado

**Capas modificadas:**
- `ApiService`: métodos `crearReceta`, `actualizarReceta`, `eliminarReceta` con JWT
- `RecetasRepository` + `RecetasDatasource`: implementación de los 3 métodos CRUD

**Fix backend:**
- `bcrypt` bajado a `4.0.1` para compatibilidad con `passlib 1.7.4` (la versión 5.x rompía el registro/login)

### 2026-03-21 — Juan
- `seed.py`: agrega recetas de Pollo, Res, Mariscos, Vegetariano, Postres y Sopas
- `custom_drawer.dart`: categorías renombradas en español para coincidir con el backend

---

## Clases completadas

- [x] Clase 01 — Estructura del proyecto Flutter
- [x] Clase 02 — Contenedores y propiedades
- [x] Clase 03 — Layout: Row, Column, Stack
- [x] Clase 04 — Textos, colores, imágenes, iconos
- [x] Clase 05 — Navegación, Drawer, Tabs
- [x] Clase 06 — Librerías, modelos, StatefulWidget
- [x] Clase 07 — Responsive con MediaQuery/LayoutBuilder
- [x] Clase 08 — Almacenamiento local (SharedPreferences)
- [x] Clase 09 — Consumo de API FastAPI propia
- [x] Clase 10 — FutureBuilder
- [x] Clase 11 — GetX: estado reactivo
- [x] Clase 12 — Bindings, Repositories, Datasources
- [x] Clase 13 — Autenticación JWT
