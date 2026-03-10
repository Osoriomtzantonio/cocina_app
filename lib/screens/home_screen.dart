import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';              // Tarjeta de receta
import '../screens/recipe_detail_screen.dart';     // Pantalla de detalle

// Pantalla principal de la aplicación
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo gris claro
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ENCABEZADO ──────────────────────────────────────
            _buildHeader(),

            // ── TARJETA: RECETA DEL DÍA ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRecetaDelDia(),
            ),

            // ── TÍTULO SECCIÓN CATEGORÍAS ────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Categorías',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── LISTA HORIZONTAL DE CATEGORÍAS ──────────────────
            _buildCategorias(),

            const SizedBox(height: 20),

            // ── TÍTULO SECCIÓN RECETAS POPULARES ────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recetas populares',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── GRID DE RECETAS POPULARES ────────────────────────
            _buildRecetasPopulares(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── WIDGET: ENCABEZADO CON DEGRADADO ────────────────────────────
  Widget _buildHeader() {
    return Container(
      // Ancho completo de la pantalla
      width: double.infinity,
      // Padding interno: espacio entre el borde y el contenido
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      // BoxDecoration permite aplicar estilos avanzados al Container
      decoration: const BoxDecoration(
        // Degradado de naranja a naranja oscuro
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE8521A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Bordes inferiores redondeados
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo
          const Text(
            '¡Hola, cocinero! 👨‍🍳',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          // Título principal
          const Text(
            '¿Qué cocinamos hoy?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          // Barra de búsqueda (visual por ahora, funcional en Clase 04+)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              // Sombra suave
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Color(0xFFFF6B35)),
                SizedBox(width: 10),
                Text(
                  'Buscar recetas...',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── WIDGET: TARJETA RECETA DEL DÍA ──────────────────────────────
  Widget _buildRecetaDelDia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        const Text(
          'Receta del día',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        // Tarjeta principal
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            // Color de fondo mientras carga la imagen
            color: const Color(0xFFFFE0CC),
            // Bordes redondeados
            borderRadius: BorderRadius.circular(20),
            // Sombra para dar profundidad
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // ClipRRect recorta los bordes de la imagen para que respete el borderRadius
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Imagen de placeholder (se reemplazará con imagen real en Clase 09)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFFFCBA4),
                  child: const Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Color(0xFFFF6B35),
                  ),
                ),
                // Overlay oscuro en la parte inferior para leer el texto
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // Degradado de transparente a negro (para contraste del texto)
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de la receta
                        Text(
                          'Teriyaki Chicken Casserole',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        // Categoría y área
                        Row(
                          children: [
                            Icon(Icons.category,
                                size: 14, color: Colors.white70),
                            SizedBox(width: 4),
                            Text(
                              'Chicken · Japanese',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── WIDGET: FILA HORIZONTAL DE CATEGORÍAS ───────────────────────
  Widget _buildCategorias() {
    // Lista de categorías de ejemplo (datos reales vendrán de la API en Clase 09)
    final categorias = [
      {'nombre': 'Chicken', 'icono': '🍗'},
      {'nombre': 'Beef', 'icono': '🥩'},
      {'nombre': 'Seafood', 'icono': '🦐'},
      {'nombre': 'Vegetarian', 'icono': '🥗'},
      {'nombre': 'Dessert', 'icono': '🍰'},
      {'nombre': 'Pasta', 'icono': '🍝'},
    ];

    return SizedBox(
      height: 100,
      // ListView horizontal para deslizar las categorías
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          return _buildCategoriaChip(
            nombre: categoria['nombre']!,
            icono: categoria['icono']!,
          );
        },
      ),
    );
  }

  // ── WIDGET: GRID DE RECETAS POPULARES ───────────────────────────
  Widget _buildRecetasPopulares() {
    // Datos de ejemplo (se reemplazarán con datos reales de la API en Clase 09)
    final recetas = [
      {
        'nombre': 'Teriyaki Chicken Casserole',
        'categoria': 'Chicken',
        'area': 'Japanese',
        'imagen': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      },
      {
        'nombre': 'Beef and Mustard Pie',
        'categoria': 'Beef',
        'area': 'British',
        'imagen': 'https://www.themealdb.com/images/media/meals/sytuqu1511553755.jpg',
      },
      {
        'nombre': 'Pad See Ew',
        'categoria': 'Pasta',
        'area': 'Thai',
        'imagen': 'https://www.themealdb.com/images/media/meals/uuuspp1468263334.jpg',
      },
      {
        'nombre': 'Spaghetti Bolognese',
        'categoria': 'Pasta',
        'area': 'Italian',
        'imagen': 'https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg',
      },
    ];

    // GridView para mostrar las tarjetas en cuadrícula de 2 columnas
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        // shrinkWrap y NeverScrollableScrollPhysics permiten que el GridView
        // viva dentro de un SingleChildScrollView sin conflictos de scroll
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,       // 2 columnas
          crossAxisSpacing: 12,    // Espacio horizontal entre tarjetas
          mainAxisSpacing: 12,     // Espacio vertical entre tarjetas
          childAspectRatio: 0.78,  // Proporción ancho/alto de cada tarjeta
        ),
        itemCount: recetas.length,
        itemBuilder: (context, index) {
          final receta = recetas[index];
          // Usamos nuestro widget RecipeCard (Row + Column + Stack)
          return RecipeCard(
            nombre: receta['nombre']!,
            categoria: receta['categoria']!,
            area: receta['area']!,
            imagenUrl: receta['imagen']!,
            onTap: () {
              // Navega a RecipeDetailScreen pasando los datos de la receta
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(
                    idMeal: '52772',
                    nombre: receta['nombre']!,
                    imagenUrl: receta['imagen']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── WIDGET: CHIP INDIVIDUAL DE CATEGORÍA ────────────────────────
  Widget _buildCategoriaChip({
    required String nombre,
    required String icono,
  }) {
    return Container(
      // Margen a la derecha entre cada chip
      margin: const EdgeInsets.only(right: 12),
      width: 80,
      // BoxDecoration con borde y sombra
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFE0CC),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji del ícono
          Text(icono, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          // Nombre de la categoría
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
