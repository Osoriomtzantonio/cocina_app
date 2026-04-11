import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart' show Share;
import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../models/recipe_model.dart';
import '../repositories/recetas_repository.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';
import '../services/recent_recipes_service.dart';
import '../services/shopping_list_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cooking_timer_widget.dart';
import '../widgets/shimmer_loading.dart';

// ══════════════════════════════════════════════════════════════
// RecipeDetailScreen — detalle de receta con FutureBuilder
//
// Funcionalidades:
//   - Mostrar imagen, nombre, categoría, área
//   - Ingredientes e instrucciones desde la API
//   - Marcar/desmarcar favorito
//   - Calificación con estrellas (requiere login)
//   - Agregar ingredientes a la lista de compras
// ══════════════════════════════════════════════════════════════

class RecipeDetailScreen extends StatefulWidget {
  final String idMeal;
  final String nombre;
  final String imagenUrl;

  const RecipeDetailScreen({
    super.key,
    required this.idMeal,
    required this.nombre,
    required this.imagenUrl,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _favoritesService = FavoritesService();
  final _shoppingService  = ShoppingListService();
  final _recentService    = RecentRecipesService();
  final _authService      = AuthService();
  late  final _repo       = Get.find<RecetasRepository>();

  // ── ESTADO ────────────────────────────────────────────────────────
  bool   _esFavorita       = false;
  double _promedio         = 0.0;
  int    _totalVotos       = 0;
  int    _miCalificacion   = 0;  // 0 = no ha calificado
  bool   _calificando      = false;

  late final Future<RecipeModel?> _futureDetalle;

  @override
  void dispose() {
    // Al cerrar la pantalla, refrescamos la lista de recientes en HomeController
    try { Get.find<HomeController>().cargarRecientes(); } catch (_) {}
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _futureDetalle = _repo.obtenerDetalle(widget.idMeal);
    _verificarSiEsFavorita();
    _cargarCalificacion();
    // Guardar en historial de recientes (con datos básicos disponibles ya)
    _recentService.guardarReceta(RecipeModel(
      idMeal:          widget.idMeal,
      strMeal:         widget.nombre,
      strCategory:     '',
      strArea:         '',
      strInstructions: '',
      strMealThumb:    widget.imagenUrl,
      ingredientes:    [],
    ));
  }

  Future<void> _verificarSiEsFavorita() async {
    final esFav = await _favoritesService.esFavorita(widget.idMeal);
    if (mounted) setState(() => _esFavorita = esFav);
  }

  // ── CARGAR PROMEDIO Y MI CALIFICACIÓN ─────────────────────────────
  Future<void> _cargarCalificacion() async {
    final datos = await _repo.obtenerCalificacion(widget.idMeal);
    if (!mounted) return;
    setState(() {
      _promedio   = (datos['promedio'] as num?)?.toDouble() ?? 0.0;
      _totalVotos = (datos['total']    as int?)             ?? 0;
    });

    // Si el usuario está logueado, cargamos su calificación personal
    final token = await _authService.obtenerToken();
    if (token != null) {
      final mia = await _repo.obtenerMiCalificacion(widget.idMeal, token);
      if (mounted) setState(() => _miCalificacion = mia);
    }
  }

  // ── CALIFICAR ─────────────────────────────────────────────────────
  Future<void> _calificar(int estrellas) async {
    final token = await _authService.obtenerToken();
    if (token == null) {
      Get.snackbar(
        'Inicia sesión',
        'Debes iniciar sesión para calificar recetas',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _calificando = true);

    final resultado =
        await _repo.calificarReceta(widget.idMeal, estrellas, token);

    if (resultado != null && mounted) {
      setState(() {
        _miCalificacion = estrellas;
        _promedio =
            (resultado['promedio'] as num?)?.toDouble() ?? _promedio;
        _totalVotos = (resultado['total'] as int?) ?? _totalVotos;
        _calificando = false;
      });
      Get.snackbar(
        '¡Gracias!',
        'Calificaste esta receta con $estrellas estrella${estrellas != 1 ? "s" : ""}',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      if (mounted) setState(() => _calificando = false);
    }
  }

  // ── TOGGLE FAVORITO ───────────────────────────────────────────────
  Future<void> _toggleFavorito() async {
    if (_esFavorita) {
      await _favoritesService.eliminarFavorito(widget.idMeal);
      if (mounted) setState(() => _esFavorita = false);
      // Get.snackbar vive en el overlay de GetX — se descarta solo al navegar
      Get.snackbar(
        '',
        'Receta eliminada de favoritos',
        titleText: const SizedBox.shrink(),
        backgroundColor: Colors.grey.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    } else {
      final receta = RecipeModel(
        idMeal:          widget.idMeal,
        strMeal:         widget.nombre,
        strCategory:     '',
        strArea:         '',
        strInstructions: '',
        strMealThumb:    widget.imagenUrl,
        ingredientes:    [],
      );
      await _favoritesService.guardarFavorito(receta);
      if (mounted) setState(() => _esFavorita = true);
      Get.snackbar(
        '',
        '¡Receta guardada en favoritos!',
        titleText: const SizedBox.shrink(),
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        mainButton: TextButton(
          onPressed: () async {
            Get.back(); // cierra el snackbar
            await _favoritesService.eliminarFavorito(widget.idMeal);
            if (mounted) setState(() => _esFavorita = false);
          },
          child: const Text('Deshacer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  // ── AGREGAR A LISTA DE COMPRAS ────────────────────────────────────
  Future<void> _agregarAListaCompras(RecipeModel receta) async {
    final agregados =
        await _shoppingService.agregarIngredientes(receta.ingredientes);

    if (!mounted) return;

    if (agregados == 0) {
      Get.snackbar(
        'Ya están en la lista',
        'Todos los ingredientes ya estaban en tu lista de compras',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        '¡Listo!',
        '$agregados ingrediente${agregados != 1 ? "s" : ""} agregado${agregados != 1 ? "s" : ""} a tu lista',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ── COMPARTIR RECETA ──────────────────────────────────────────────
  // Comparte el nombre, categoría e ingredientes como texto plano
  Future<void> _compartir() async {
    // Intentamos obtener los datos completos si ya cargaron
    RecipeModel? detalle;
    try {
      detalle = await _futureDetalle;
    } catch (_) {}

    final nombre      = detalle?.strMeal      ?? widget.nombre;
    final categoria   = detalle?.strCategory  ?? '';
    final ingredientes = detalle?.ingredientes ?? [];

    final buffer = StringBuffer();
    buffer.writeln('🍳 *$nombre*');
    if (categoria.isNotEmpty) buffer.writeln('📂 Categoría: $categoria');
    buffer.writeln();

    if (ingredientes.isNotEmpty) {
      buffer.writeln('🛒 *Ingredientes:*');
      for (final ing in ingredientes) {
        final nombre  = ing['ingrediente'] ?? '';
        final cantidad = ing['cantidad']   ?? '';
        if (nombre.isNotEmpty) {
          buffer.writeln(
              '• $nombre${cantidad.isNotEmpty ? " — $cantidad" : ""}');
        }
      }
    }

    buffer.writeln();
    buffer.writeln('Receta compartida desde CocinaApp 🍽️');

    await Share.share(buffer.toString(), subject: nombre);
  }

  @override
  Widget build(BuildContext context) {
    // ScaffoldMessenger local: los SnackBars quedan atados a ESTA pantalla.
    // Cuando el usuario navega atrás, este messenger se destruye junto con
    // sus SnackBars. Así nunca "escapan" a la pantalla anterior.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FutureBuilder<RecipeModel?>(
              future: _futureDetalle,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildContenidoCargando();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildContenidoError();
                }
                return _buildContenido(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR ────────────────────────────────────────────────
  Widget _buildSliverAppBar() {
    // expandedHeight responsivo: 30% del alto de pantalla (mín 220, máx 350)
    final expandedHeight = (MediaQuery.of(context).size.height * 0.30)
        .clamp(220.0, 350.0);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleFavorito,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _esFavorita ? Icons.favorite : Icons.favorite_border,
              color: _esFavorita ? Colors.red[300] : Colors.white,
              size: 20,
            ),
          ),
        ),
        IconButton(
          onPressed: _compartir,
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImagenPrincipal(),
      ),
    );
  }

  // ── IMAGEN PRINCIPAL ──────────────────────────────────────────────
  Widget _buildImagenPrincipal() {
    final esAsset = widget.imagenUrl.startsWith('assets/');
    final sinImagen = widget.imagenUrl.isEmpty;

    Widget imagenWidget;
    if (sinImagen) {
      imagenWidget = Container(
        color: AppColors.primaryLight,
        child: const Icon(Icons.restaurant, size: 80, color: AppColors.primary),
      );
    } else if (esAsset) {
      imagenWidget = Image.asset(
        widget.imagenUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          color: AppColors.primaryLight,
          child: const Icon(Icons.broken_image, size: 64, color: AppColors.primary),
        ),
      );
    } else {
      imagenWidget = Image.network(
        widget.imagenUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.primaryLight,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
        errorBuilder: (context, error, stack) => Container(
          color: AppColors.primaryLight,
          child: const Icon(Icons.broken_image,
              size: 64, color: AppColors.primary),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imagenWidget,
        Positioned(
          bottom: 0, left: 0, right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── CARGANDO (shimmer skeleton) ──────────────────────────────────
  Widget _buildContenidoCargando() {
    return ShimmerLoading.recipeDetail(context);
  }

  // ── ERROR ─────────────────────────────────────────────────────────
  Widget _buildContenidoError() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Text(widget.nombre, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          const Icon(Icons.wifi_off, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'No se pudieron cargar los detalles.\nVerifica tu conexión.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  // ── CONTENIDO COMPLETO ────────────────────────────────────────────
  Widget _buildContenido(RecipeModel receta) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(receta.strMeal, style: Theme.of(context).textTheme.headlineMedium),

          const SizedBox(height: 12),
          _buildMetadataBadges(receta),

          // ── SECCIÓN CALIFICACIÓN ──────────────────────────────────
          const SizedBox(height: 20),
          _buildSeccionCalificacion(),

          const SizedBox(height: 20),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 20),

          _buildSeccionIngredientes(receta),

          // ── BOTÓN LISTA DE COMPRAS ────────────────────────────────
          if (receta.ingredientes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildBotonListaCompras(receta),
          ],

          const SizedBox(height: 24),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 20),

          _buildSeccionInstrucciones(receta),

          // ── TIMER DE COCINA ───────────────────────────────────────
          const SizedBox(height: 24),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 20),
          const CookingTimerWidget(),

          // ── RECETAS SIMILARES ───────────────────────────────────
          if (receta.strCategory.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(color: AppColors.grey200, height: 1),
            const SizedBox(height: 20),
            _buildRecetasSimilares(receta),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── BADGES ────────────────────────────────────────────────────────
  Widget _buildMetadataBadges(RecipeModel receta) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        if (receta.strCategory.isNotEmpty)
          _buildBadge(icon: Icons.restaurant_menu, texto: receta.strCategory),
        if (receta.strArea.isNotEmpty)
          _buildBadge(icon: Icons.public, texto: receta.strArea),
        _buildBadge(icon: Icons.timer, texto: '~30-45 min'),
      ],
    );
  }

  Widget _buildBadge({required IconData icon, required String texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(texto,
              style:
                  AppTextStyles.label.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }

  // ── SECCIÓN CALIFICACIÓN ──────────────────────────────────────────
  Widget _buildSeccionCalificacion() {
    final authCtrl = Get.find<AuthController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── PROMEDIO ACTUAL ────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
              const SizedBox(width: 6),
              Text(
                _promedio > 0
                    ? _promedio.toStringAsFixed(1)
                    : 'Sin calificaciones',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_totalVotos > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '($_totalVotos voto${_totalVotos != 1 ? "s" : ""})',
                  style: TextStyle(
                      fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ],
          ),

          // Barra visual del promedio
          if (_promedio > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _promedio / 5,
                minHeight: 6,
                backgroundColor: AppColors.grey200,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.grey200),
          const SizedBox(height: 14),

          // ── ESTRELLAS INTERACTIVAS ────────────────────────────
          Obx(() {
            final logueado = authCtrl.estaLogueado.value;

            if (!logueado) {
              return Row(
                children: [
                  Icon(Icons.lock_outline,
                      size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 6),
                  Text(
                    'Inicia sesión para calificar',
                    style: AppTextStyles.label
                        .copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _miCalificacion > 0
                      ? 'Tu calificación:'
                      : 'Califica esta receta:',
                  style: AppTextStyles.label
                      .copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                const SizedBox(height: 8),
                _calificando
                    ? const SizedBox(
                        height: 36,
                        width: 36,
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2),
                      )
                    : _buildEstrellas(),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── ESTRELLAS INTERACTIVAS ────────────────────────────────────────
  Widget _buildEstrellas() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final num = i + 1;
        final activa = num <= _miCalificacion;
        return GestureDetector(
          onTap: () => _calificar(num),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              activa ? Icons.star_rounded : Icons.star_outline_rounded,
              color: activa ? Colors.amber : AppColors.grey200,
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  // ── BOTÓN LISTA DE COMPRAS ────────────────────────────────────────
  Widget _buildBotonListaCompras(RecipeModel receta) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _agregarAListaCompras(receta),
        icon: const Icon(Icons.shopping_cart_outlined,
            color: AppColors.primary, size: 20),
        label: const Text(
          'Agregar ingredientes a lista de compras',
          style: TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── INGREDIENTES ──────────────────────────────────────────────────
  Widget _buildSeccionIngredientes(RecipeModel receta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.kitchen, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('Ingredientes', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 14),
        ...receta.ingredientes.map(
          (item) => _buildIngredienteItem(
            ingrediente: item['ingrediente'] ?? '',
            cantidad:    item['cantidad']    ?? '',
          ),
        ),
      ],
    );
  }

  Widget _buildIngredienteItem(
      {required String ingrediente, required String cantidad}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(ingrediente, style: Theme.of(context).textTheme.bodyMedium)),
          Text(
            cantidad,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── INSTRUCCIONES ─────────────────────────────────────────────────
  Widget _buildSeccionInstrucciones(RecipeModel receta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_list_numbered,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('Instrucciones', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 14),
        if (receta.strInstructions.isEmpty)
          Text('Instrucciones no disponibles.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).textTheme.bodySmall?.color))
        else
          _buildPasos(receta.strInstructions),
      ],
    );
  }

  // ── RECETAS SIMILARES ─────────────────────────────────────────────
  Widget _buildRecetasSimilares(RecipeModel receta) {
    final api = ApiService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('También te puede gustar', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<RecipeModel>>(
          future: api.obtenerRecetasPorCategoria(receta.strCategory),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ShimmerLoading.horizontalCards(context);
            }
            if (!snap.hasData || snap.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            // Filtrar la receta actual y limitar a 8
            final similares = snap.data!
                .where((r) => r.idMeal != widget.idMeal)
                .take(8)
                .toList();

            if (similares.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similares.length,
                itemBuilder: (context, i) {
                  final r = similares[i];
                  return _buildSimilarCard(r);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSimilarCard(RecipeModel receta) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RecipeDetailScreen(
            idMeal:    receta.idMeal,
            nombre:    receta.strMeal,
            imagenUrl: receta.strMealThumb,
          ),
        ),
      ),
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                receta.strMealThumb,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 100,
                  color: const Color(0xFFFFE0CC),
                  child:
                      const Icon(Icons.restaurant, color: AppColors.primary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                receta.strMeal,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasos(String instrucciones) {
    final pasos = instrucciones
        .split(RegExp(r'\r\n|\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Column(
      children: pasos.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28, height: 28,
                decoration: const BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(e.value, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
