import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../services/favorites_service.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 09 — RecipeDetailScreen con datos reales de la API
// ══════════════════════════════════════════════════════════════
//
// Novedad: cargamos el detalle completo al abrir la pantalla
//   - ingredientes reales (hasta 20)
//   - instrucciones reales
//   - categoría y área reales
//
// initState() lanza DOS operaciones en paralelo:
//   1. _verificarSiEsFavorita() — SharedPreferences (ya existía)
//   2. _cargarDetalle()         — API lookup.php (nueva en Clase 09)

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

  // Estado: favorito
  bool _esFavorita = false;

  // Estado: detalle de la receta
  RecipeModel? _receta;
  bool _cargandoDetalle = true;
  bool _errorDetalle = false;

  @override
  void initState() {
    super.initState();
    // Lanzamos ambas operaciones en paralelo sin bloquear la UI
    _verificarSiEsFavorita();
    _cargarDetalle();
  }

  // ── VERIFICAR FAVORITO (igual que antes, usa SharedPreferences) ───
  Future<void> _verificarSiEsFavorita() async {
    final esFav = await _favoritesService.esFavorita(widget.idMeal);
    if (mounted) setState(() => _esFavorita = esFav);
  }

  // ── CARGAR DETALLE DESDE LA API ───────────────────────────────────
  Future<void> _cargarDetalle() async {
    setState(() {
      _cargandoDetalle = true;
      _errorDetalle = false;
    });

    // await espera el endpoint lookup.php con todos los detalles
    final receta = await _api.obtenerDetalle(widget.idMeal);

    if (!mounted) return;

    if (receta == null) {
      setState(() {
        _cargandoDetalle = false;
        _errorDetalle = true;
      });
      return;
    }

    setState(() {
      _cargandoDetalle = false;
      _receta = receta;
    });
  }

  // ── TOGGLE FAVORITO ───────────────────────────────────────────────
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
      // Usamos los datos reales si ya cargaron, o los básicos si no
      final receta = _receta ??
          RecipeModel(
            idMeal: widget.idMeal,
            strMeal: widget.nombre,
            strCategory: '',
            strArea: '',
            strInstructions: '',
            strMealThumb: widget.imagenUrl,
            ingredientes: [],
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
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildContenido()),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR CON IMAGEN ─────────────────────────────────────
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
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.primaryLight,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => Container(
            color: AppColors.primaryLight,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 64, color: AppColors.primary),
                SizedBox(height: 8),
                Text('No se pudo cargar la imagen',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
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

  // ── CONTENIDO PRINCIPAL ───────────────────────────────────────────
  Widget _buildContenido() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre (de los parámetros — disponible de inmediato)
          Text(widget.nombre, style: AppTextStyles.heading2),

          const SizedBox(height: 12),

          // Badges: se muestran con datos reales cuando cargan
          _buildMetadataBadges(),

          const SizedBox(height: 24),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 20),

          // Ingredientes e instrucciones: muestran spinner o datos reales
          _buildSeccionIngredientes(),

          const SizedBox(height: 24),
          const Divider(color: AppColors.grey200, height: 1),
          const SizedBox(height: 20),

          _buildSeccionInstrucciones(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── BADGES DE METADATA ────────────────────────────────────────────
  Widget _buildMetadataBadges() {
    // Si ya cargaron los datos reales, los usamos; si no, mostramos '...'
    final categoria = _receta?.strCategory ?? '...';
    final area      = _receta?.strArea      ?? '...';

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _buildBadge(icon: Icons.restaurant_menu, texto: categoria),
        _buildBadge(icon: Icons.public,          texto: area),
        // Tiempo siempre es estimado (la API no lo provee)
        _buildBadge(icon: Icons.timer,           texto: '~30-45 min'),
      ],
    );
  }

  // ── BADGE INDIVIDUAL ──────────────────────────────────────────────
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
          Text(
            texto,
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN: INGREDIENTES ─────────────────────────────────────────
  Widget _buildSeccionIngredientes() {
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

        // Si está cargando → spinner
        if (_cargandoDetalle)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        // Si hubo error → mensaje
        else if (_errorDetalle)
          _buildMensajeError()
        // Si ya cargaron → lista real de ingredientes
        else
          ...(_receta?.ingredientes ?? []).map(
            (item) => _buildIngredienteItem(
              ingrediente: item['ingrediente'] ?? '',
              cantidad:    item['cantidad']    ?? '',
            ),
          ),
      ],
    );
  }

  // ── SECCIÓN: INSTRUCCIONES ────────────────────────────────────────
  Widget _buildSeccionInstrucciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_list_numbered,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('Instrucciones', style: AppTextStyles.heading3),
          ],
        ),
        const SizedBox(height: 14),

        if (_cargandoDetalle)
          const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        else if (_errorDetalle)
          _buildMensajeError()
        else
          _buildPasosInstrucciones(_receta?.strInstructions ?? ''),
      ],
    );
  }

  // ── MENSAJE DE ERROR INLINE ───────────────────────────────────────
  Widget _buildMensajeError() {
    return Column(
      children: [
        const Icon(Icons.wifi_off, color: AppColors.primary, size: 40),
        const SizedBox(height: 8),
        Text(
          'No se pudieron cargar los datos.\nVerifica tu conexión.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: _cargarDetalle,
          icon: const Icon(Icons.refresh, color: AppColors.primary),
          label: const Text('Reintentar',
              style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }

  // ── FILA DE UN INGREDIENTE ────────────────────────────────────────
  Widget _buildIngredienteItem(
      {required String ingrediente, required String cantidad}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(ingrediente, style: AppTextStyles.bodyMedium),
          ),
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

  // ── INSTRUCCIONES DIVIDIDAS EN PASOS ─────────────────────────────
  // La API devuelve las instrucciones como un String largo.
  // Las dividimos por punto o salto de línea para mostrar como pasos.
  Widget _buildPasosInstrucciones(String instrucciones) {
    if (instrucciones.isEmpty) {
      return Text(
        'Instrucciones no disponibles.',
        style: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textSecondary),
      );
    }

    // Dividimos el texto en pasos: por '\r\n' o por '. ' al final de oración
    final pasos = instrucciones
        .split(RegExp(r'\r\n|\n'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Column(
      children: pasos.asMap().entries.map((entry) {
        return _buildPasoItem(
          numero: entry.key + 1,
          descripcion: entry.value,
        );
      }).toList(),
    );
  }

  // ── FILA DE UN PASO ───────────────────────────────────────────────
  Widget _buildPasoItem(
      {required int numero, required String descripcion}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$numero',
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
            child: Text(descripcion, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
