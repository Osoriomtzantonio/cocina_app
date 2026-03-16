import 'package:flutter/material.dart';
import '../widgets/recipe_grid.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 09 — HomeScreen conectada a la API real
// ══════════════════════════════════════════════════════════════
//
// Patrón de carga con setState (manual):
//   1. initState() llama a _cargarDatos()
//   2. _cargarDatos() es async: usa await para esperar la API
//   3. Cuando llegan los datos, setState() redibuja la pantalla
//
// Estados posibles:
//   _cargandoInicial = true  → muestra spinner
//   _error != null           → muestra mensaje de error + botón reintentar
//   datos cargados           → muestra el contenido real

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── SERVICIO DE API ───────────────────────────────────────────────
  final ApiService _api = ApiService();

  // ── ESTADO: CARGA Y ERROR ─────────────────────────────────────────
  bool _cargandoInicial = true;
  String? _error;

  // ── ESTADO: RECETA DEL DÍA ────────────────────────────────────────
  RecipeModel? _recetaDia;
  bool _cargandoReceta = false; // spinner del botón de refrescar

  // ── ESTADO: CATEGORÍAS Y RECETAS POPULARES ────────────────────────
  List<CategoryModel> _categorias = [];
  List<RecipeModel> _recetasPopulares = [];

  // ── initState: se ejecuta UNA VEZ al crear el widget ─────────────
  // Lugar correcto para lanzar la carga inicial de datos
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ── CARGA INICIAL: receta del día + categorías + populares ────────
  Future<void> _cargarDatos() async {
    setState(() {
      _cargandoInicial = true;
      _error = null;
    });

    // Future.wait ejecuta las tres peticiones EN PARALELO
    // Es más eficiente que usar await una por una
    final resultados = await Future.wait([
      _api.obtenerRecetaAleatoria(),   // índice 0
      _api.obtenerCategorias(),        // índice 1
      _api.buscarRecetas('chicken'),   // índice 2 — usamos como "populares"
    ]);

    // Si el widget fue destruido mientras esperábamos, no actualizamos
    if (!mounted) return;

    final receta     = resultados[0] as RecipeModel?;
    final categorias = resultados[1] as List<CategoryModel>;
    final populares  = resultados[2] as List<RecipeModel>;

    // Si no llegó ni la receta ni las categorías → mostramos error
    if (receta == null && categorias.isEmpty) {
      setState(() {
        _cargandoInicial = false;
        _error = 'Sin conexión a internet.\nVerifica tu red e intenta de nuevo.';
      });
      return;
    }

    setState(() {
      _cargandoInicial  = false;
      _recetaDia        = receta;
      _categorias       = categorias;
      // Limitamos a 6 recetas para no saturar el grid
      _recetasPopulares = populares.length > 6 ? populares.sublist(0, 6) : populares;
    });
  }

  // ── REFRESCAR RECETA DEL DÍA ──────────────────────────────────────
  Future<void> _recargarRecetaDia() async {
    setState(() => _cargandoReceta = true);

    // await espera la respuesta de la API antes de continuar
    final nueva = await _api.obtenerRecetaAleatoria();

    if (!mounted) return;

    setState(() {
      _cargandoReceta = false;
      if (nueva != null) _recetaDia = nueva; // solo actualizamos si llegó algo
    });
  }

  @override
  Widget build(BuildContext context) {
    // ── ESTADO DE CARGA INICIAL ───────────────────────────────────
    if (_cargandoInicial) return _buildCargando();

    // ── ESTADO DE ERROR ───────────────────────────────────────────
    if (_error != null) return _buildError();

    // ── CONTENIDO NORMAL ─────────────────────────────────────────
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        // El usuario puede hacer pull-to-refresh para recargar todo
        onRefresh: _cargarDatos,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildRecetaDelDia(),
              ),

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
              _buildCategorias(),

              const SizedBox(height: 20),

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
              _buildRecetasPopulares(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── PANTALLA DE CARGA INICIAL ─────────────────────────────────────
  Widget _buildCargando() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              'Cargando recetas...',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ── PANTALLA DE ERROR CON BOTÓN REINTENTAR ────────────────────────
  Widget _buildError() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 72, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarDatos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ENCABEZADO CON DEGRADADO ──────────────────────────────────────
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

  // ── TARJETA: RECETA DEL DÍA (datos reales de la API) ─────────────
  Widget _buildRecetaDelDia() {
    if (_recetaDia == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            // Botón de recarga: ahora llama a la API real
            IconButton(
              onPressed: _cargandoReceta ? null : _recargarRecetaDia,
              icon: _cargandoReceta
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(Icons.refresh, color: AppColors.primary),
              tooltip: 'Nueva receta aleatoria',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // AnimatedSwitcher anima la transición entre recetas
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildTarjetaReceta(
            // ValueKey hace que AnimatedSwitcher detecte el cambio de receta
            key: ValueKey(_recetaDia!.idMeal),
            receta: _recetaDia!,
          ),
        ),
      ],
    );
  }

  // ── TARJETA VISUAL DE RECETA ──────────────────────────────────────
  Widget _buildTarjetaReceta({required Key key, required RecipeModel receta}) {
    return AnimatedOpacity(
      key: key,
      opacity: _cargandoReceta ? 0.4 : 1.0,
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
              Positioned.fill(
                child: Image.network(
                  receta.strMealThumb,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: const Color(0xFFFFCBA4),
                    child: const Icon(Icons.restaurant,
                        size: 80, color: Color(0xFFFF6B35)),
                  ),
                ),
              ),
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
                      // Nombre REAL de la API
                      Text(
                        receta.strMeal,
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
                          // Categoría y área REALES de la API
                          Text(
                            '${receta.strCategory} · ${receta.strArea}',
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
    );
  }

  // ── LISTA HORIZONTAL DE CATEGORÍAS (imágenes reales de la API) ───
  Widget _buildCategorias() {
    if (_categorias.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // Mostramos las primeras 8 categorías
        itemCount: _categorias.length > 8 ? 8 : _categorias.length,
        itemBuilder: (context, index) {
          return _buildCategoriaChip(_categorias[index]);
        },
      ),
    );
  }

  // ── CHIP DE CATEGORÍA CON IMAGEN REAL ────────────────────────────
  Widget _buildCategoriaChip(CategoryModel categoria) {
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
          // Imagen real de la categoría desde la API
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              categoria.strCategoryThumb,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            categoria.strCategory,
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

  // ── GRID DE RECETAS POPULARES (datos reales de la API) ───────────
  Widget _buildRecetasPopulares() {
    if (_recetasPopulares.isEmpty) return const SizedBox.shrink();
    return RecipeGrid(recetas: _recetasPopulares, shrinkWrap: true);
  }
}
