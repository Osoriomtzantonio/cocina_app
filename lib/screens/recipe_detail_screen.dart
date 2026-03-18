import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 10 — RecipeDetailScreen con FutureBuilder
// ══════════════════════════════════════════════════════════════
//
// Comparación con Clase 09 (setState manual):
//
//   Clase 09:
//     bool _cargandoDetalle = true;
//     bool _errorDetalle = false;
//     RecipeModel? _receta;
//     Future<void> _cargarDetalle() async {
//       setState(() => _cargandoDetalle = true);
//       final r = await _api.obtenerDetalle(id);
//       setState(() { _cargandoDetalle = false; _receta = r; });
//     }
//
//   Clase 10 (FutureBuilder):
//     late final Future<RecipeModel?> _futureDetalle;  // ← solo esto
//     // No hay bool _cargando ni bool _error — FutureBuilder los maneja
//
// FutureBuilder tiene 4 estados via snapshot.connectionState:
//   - none    → el Future es null
//   - waiting → el Future todavía no resolvió (cargando)
//   - active  → solo para Streams
//   - done    → el Future terminó (éxito o error)
//
// Diseño de esta pantalla:
//   - SliverAppBar: muestra imagen y título INMEDIATAMENTE (de los parámetros)
//   - Contenido:    usa FutureBuilder para ingredientes e instrucciones reales

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
  final FavoritesService _favoritesService = FavoritesService();
  final ApiService _api = ApiService();

  // ── ESTADO: favorito (aún usa setState porque es interacción del usuario)
  bool _esFavorita = false;

  // ── FUTURE: se crea UNA VEZ en initState ─────────────────────────
  // late final = se inicializa después de declararse pero antes de usarse
  // final      = no puede reasignarse (garantiza que no se recrea en rebuild)
  late final Future<RecipeModel?> _futureDetalle;

  @override
  void initState() {
    super.initState();
    // Guardamos el Future en una variable — esto es clave para FutureBuilder
    _futureDetalle = _api.obtenerDetalle(widget.idMeal);
    _verificarSiEsFavorita();
  }

  Future<void> _verificarSiEsFavorita() async {
    final esFav = await _favoritesService.esFavorita(widget.idMeal);
    if (mounted) setState(() => _esFavorita = esFav);
  }

  Future<void> _toggleFavorito() async {
    if (_esFavorita) {
      await _favoritesService.eliminarFavorito(widget.idMeal);
      if (mounted) {
        setState(() => _esFavorita = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receta eliminada de favoritos'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Intentamos usar los datos completos si ya cargaron;
      // si no, usamos los datos básicos que llegaron como parámetros
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
      if (mounted) {
        setState(() => _esFavorita = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Receta guardada en favoritos! ✓'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: Colors.white,
              onPressed: () async {
                await _favoritesService.eliminarFavorito(widget.idMeal);
                if (mounted) setState(() => _esFavorita = false);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // La imagen y el título se muestran INMEDIATAMENTE (no esperan la API)
          _buildSliverAppBar(),

          // El contenido usa FutureBuilder — espera los datos del servidor
          SliverToBoxAdapter(
            child: FutureBuilder<RecipeModel?>(
              // Pasamos la referencia al Future almacenado (no creamos uno nuevo)
              future: _futureDetalle,
              builder: (context, snapshot) {
                // ── ESTADO: esperando respuesta ─────────────────────
                // ConnectionState.waiting = el Future aún no terminó
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildContenidoCargando();
                }

                // ── ESTADO: error o datos nulos ─────────────────────
                // snapshot.hasError = el Future lanzó una excepción
                // !snapshot.hasData = el Future terminó pero devolvió null
                if (snapshot.hasError || !snapshot.hasData) {
                  return _buildContenidoError();
                }

                // ── ESTADO: datos listos ────────────────────────────
                // snapshot.data! = el RecipeModel con todos los detalles reales
                return _buildContenido(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR (inmediato — no necesita FutureBuilder) ────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
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
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildImagenPrincipal(),
      ),
    );
  }

  // ── IMAGEN PRINCIPAL ──────────────────────────────────────────────
  Widget _buildImagenPrincipal() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
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
            child: const Icon(Icons.broken_image, size: 64, color: AppColors.primary),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── CONTENIDO: CARGANDO ───────────────────────────────────────────
  Widget _buildContenidoCargando() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Nombre disponible de inmediato (parámetro)
          Text(widget.nombre, style: AppTextStyles.heading2),
          const SizedBox(height: 32),
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Cargando ingredientes e instrucciones...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  // ── CONTENIDO: ERROR ──────────────────────────────────────────────
  Widget _buildContenidoError() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Text(widget.nombre, style: AppTextStyles.heading2),
          const SizedBox(height: 32),
          const Icon(Icons.wifi_off, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'No se pudieron cargar los detalles.\nVerifica tu conexión.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  // ── CONTENIDO: DATOS REALES (snapshot.data!) ─────────────────────
  Widget _buildContenido(RecipeModel receta) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(receta.strMeal, style: AppTextStyles.heading2),

          const SizedBox(height: 12),
          _buildMetadataBadges(receta),

          const SizedBox(height: 24),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 20),

          _buildSeccionIngredientes(receta),

          const SizedBox(height: 24),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 20),

          _buildSeccionInstrucciones(receta),
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
        _buildBadge(icon: Icons.restaurant_menu, texto: receta.strCategory),
        _buildBadge(icon: Icons.public,          texto: receta.strArea),
        _buildBadge(icon: Icons.timer,           texto: '~30-45 min'),
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
          Text(texto, style: AppTextStyles.label.copyWith(color: AppColors.primary)),
        ],
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
            Text('Ingredientes', style: AppTextStyles.heading3),
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

  Widget _buildIngredienteItem({required String ingrediente, required String cantidad}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary, shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(ingrediente, style: AppTextStyles.bodyMedium)),
          Text(
            cantidad,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary, fontWeight: FontWeight.w600,
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
            const Icon(Icons.format_list_numbered, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('Instrucciones', style: AppTextStyles.heading3),
          ],
        ),
        const SizedBox(height: 14),
        if (receta.strInstructions.isEmpty)
          Text('Instrucciones no disponibles.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
        else
          _buildPasos(receta.strInstructions),
      ],
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
                  color: AppColors.primary, shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: AppTextStyles.bodyMedium)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
