import 'package:flutter/material.dart';
import '../widgets/recipe_card.dart';
import '../screens/recipe_detail_screen.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart'; // Importamos el modelo de receta

// ── STATEFULWIDGET ────────────────────────────────────────────────────
// Usamos StatefulWidget porque HomeScreen tiene estado que cambia:
// - El indicador de carga (cargando: true/false)
// - La receta del día (puede recargarse)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// La clase State contiene todas las variables de estado y la lógica
class _HomeScreenState extends State<HomeScreen> {

  // ── VARIABLES DE ESTADO ────────────────────────────────────────
  // Cuando estas variables cambian y llamamos setState(), la pantalla se redibuja

  // Indica si está cargando la receta del día
  bool _cargando = false;

  // Índice de la receta del día mostrada actualmente (para simular "aleatoria")
  int _indiceRecetaDia = 0;

  // Datos de ejemplo para la receta del día
  // En Clase 09 esto vendrá de la API /random.php
  final List<Map<String, String>> _recetasDia = [
    {
      'nombre': 'Teriyaki Chicken Casserole',
      'categoria': 'Chicken · Japanese',
      'imagen': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
    },
    {
      'nombre': 'Beef and Mustard Pie',
      'categoria': 'Beef · British',
      'imagen': 'https://www.themealdb.com/images/media/meals/sytuqu1511553755.jpg',
    },
    {
      'nombre': 'Spaghetti Bolognese',
      'categoria': 'Pasta · Italian',
      'imagen': 'https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg',
    },
  ];

  // ── MÉTODO: simula recargar la receta del día ──────────────────
  // Demuestra cómo setState() redibuja la pantalla
  void _recargarRecetaDia() {
    // setState() le dice a Flutter: "el estado cambió, vuelve a dibujar"
    setState(() {
      _cargando = true; // Muestra el indicador de carga
    });

    // Simulamos una espera de 1.5 segundos (como si fuera una petición real)
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        // Cambia al siguiente índice (vuelve al 0 si llegó al final)
        _indiceRecetaDia = (_indiceRecetaDia + 1) % _recetasDia.length;
        _cargando = false; // Oculta el indicador de carga
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // La receta actual según el índice de estado
    final recetaDia = _recetasDia[_indiceRecetaDia];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ENCABEZADO ──────────────────────────────────────
            _buildHeader(),

            // ── TARJETA: RECETA DEL DÍA ─────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRecetaDelDia(recetaDia),
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE8521A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¡Hola, cocinero! 👨‍🍳',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          const Text(
            '¿Qué cocinamos hoy?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
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
  // Ahora recibe la receta como parámetro (viene del estado)
  Widget _buildRecetaDelDia(Map<String, String> receta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila con el título y el botón de recargar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Receta del día',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            // Botón de recargar — llama a _recargarRecetaDia() que usa setState()
            IconButton(
              onPressed: _cargando ? null : _recargarRecetaDia,
              icon: _cargando
                  // Si está cargando, muestra un spinner pequeño
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  // Si no está cargando, muestra el ícono de refresh
                  : const Icon(Icons.refresh, color: AppColors.primary),
              tooltip: 'Nueva receta',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tarjeta principal con animación de opacidad al cambiar
        AnimatedOpacity(
          // AnimatedOpacity anima el cambio de opacidad automáticamente
          opacity: _cargando ? 0.4 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE0CC),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Imagen desde URL usando el modelo de receta
                  Positioned.fill(
                    child: Image.network(
                      receta['imagen']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFFFCBA4),
                        child: const Icon(Icons.restaurant,
                            size: 80, color: Color(0xFFFF6B35)),
                      ),
                    ),
                  ),
                  // Overlay con nombre y categoría
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // El nombre viene del estado (_recetasDia[_indiceRecetaDia])
                          Text(
                            receta['nombre']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.category,
                                  size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                receta['categoria']!,
                                style: const TextStyle(
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
        ),
      ],
    );
  }

  // ── WIDGET: FILA HORIZONTAL DE CATEGORÍAS ───────────────────────
  Widget _buildCategorias() {
    final categorias = [
      {'nombre': 'Chicken',    'icono': '🍗'},
      {'nombre': 'Beef',       'icono': '🥩'},
      {'nombre': 'Seafood',    'icono': '🦐'},
      {'nombre': 'Vegetarian', 'icono': '🥗'},
      {'nombre': 'Dessert',    'icono': '🍰'},
      {'nombre': 'Pasta',      'icono': '🍝'},
    ];

    return SizedBox(
      height: 100,
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
    // Usamos RecipeModel para estructurar los datos (aunque aún son estáticos)
    final recetas = [
      RecipeModel(
        idMeal: '52772', strMeal: 'Teriyaki Chicken Casserole',
        strCategory: 'Chicken', strArea: 'Japanese',
        strInstructions: '', ingredientes: [],
        strMealThumb: 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      ),
      RecipeModel(
        idMeal: '52997', strMeal: 'Beef and Mustard Pie',
        strCategory: 'Beef', strArea: 'British',
        strInstructions: '', ingredientes: [],
        strMealThumb: 'https://www.themealdb.com/images/media/meals/sytuqu1511553755.jpg',
      ),
      RecipeModel(
        idMeal: '52944', strMeal: 'Pad See Ew',
        strCategory: 'Pasta', strArea: 'Thai',
        strInstructions: '', ingredientes: [],
        strMealThumb: 'https://www.themealdb.com/images/media/meals/uuuspp1468263334.jpg',
      ),
      RecipeModel(
        idMeal: '52770', strMeal: 'Spaghetti Bolognese',
        strCategory: 'Pasta', strArea: 'Italian',
        strInstructions: '', ingredientes: [],
        strMealThumb: 'https://www.themealdb.com/images/media/meals/sutysw1468247559.jpg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: recetas.length,
        itemBuilder: (context, index) {
          final receta = recetas[index];
          return RecipeCard(
            nombre: receta.strMeal,
            categoria: receta.strCategory,
            area: receta.strArea,
            imagenUrl: receta.strMealThumb,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(
                    idMeal: receta.idMeal,
                    nombre: receta.strMeal,
                    imagenUrl: receta.strMealThumb,
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
  Widget _buildCategoriaChip({required String nombre, required String icono}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFFFE0CC), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icono, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
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
