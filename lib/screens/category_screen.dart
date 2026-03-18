import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../utils/responsive_helper.dart';
import '../widgets/recipe_grid.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 10 — CategoryScreen con FutureBuilder
// ══════════════════════════════════════════════════════════════
//
// Comparación directa con Clase 09:
//
//   Clase 09 (setState manual):
//     bool _cargando = true;
//     String? _error;
//     List<RecipeModel> _recetas = [];
//
//     Future<void> _cargarRecetas() async {
//       setState(() => _cargando = true);
//       final r = await _api.obtenerRecetasPorCategoria(categoria);
//       setState(() { _cargando = false; _recetas = r; });
//     }
//
//   Clase 10 (FutureBuilder):
//     late final Future<List<RecipeModel>> _futureRecetas;  // solo esto
//     // No hay bool _cargando ni String _error — FutureBuilder lo hace todo

class CategoryScreen extends StatefulWidget {
  final String categoria;

  const CategoryScreen({super.key, required this.categoria});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _api = ApiService();

  // ── EL FUTURE SE CREA UNA VEZ ────────────────────────────────────
  // late final garantiza que no se recrea en cada rebuild
  late final Future<List<RecipeModel>> _futureRecetas;

  @override
  void initState() {
    super.initState();
    // Lanzamos la petición y guardamos el Future
    _futureRecetas = _api
        .obtenerRecetasPorCategoria(widget.categoria)
        .then((lista) =>
            // Inyectamos la categoría porque filter endpoint no la incluye
            lista.map((r) => r.copyWith(strCategory: widget.categoria)).toList());
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.categoria,
          style: TextStyle(fontSize: responsive.fontSizeTitulo),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<RecipeModel>>(
        future: _futureRecetas,
        builder: (context, snapshot) {
          // ── ESTADO: waiting ─────────────────────────────────────
          // El Future aún no terminó — mostramos encabezado con "..."
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                _buildEncabezado('...', responsive),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ],
            );
          }

          // ── ESTADO: done con error ───────────────────────────────
          // El Future terminó pero lanzó una excepción
          if (snapshot.hasError) {
            return _buildEstadoError(snapshot.error.toString());
          }

          // ── ESTADO: done con datos ───────────────────────────────
          // snapshot.data puede ser una lista vacía o con elementos
          final recetas = snapshot.data ?? [];

          if (recetas.isEmpty) {
            return _buildSinResultados();
          }

          return Column(
            children: [
              _buildEncabezado('${recetas.length}', responsive),
              Expanded(child: RecipeGrid(recetas: recetas)),
            ],
          );
        },
      ),
    );
  }

  // ── ENCABEZADO ────────────────────────────────────────────────────
  Widget _buildEncabezado(String total, ResponsiveHelper responsive) {
    final tipoDispositivo = responsive.esTabletGrande
        ? 'Tablet grande (4 cols)'
        : responsive.esTablet
            ? 'Tablet (3 cols)'
            : responsive.esHorizontal
                ? 'Horizontal (3 cols)'
                : 'Celular (2 cols)';

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
          responsive.paddingHorizontal, 0, responsive.paddingHorizontal, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, color: Colors.white70, size: 15),
              const SizedBox(width: 6),
              Text(
                '$total recetas',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  responsive.esCelular ? Icons.smartphone : Icons.tablet_mac,
                  color: Colors.white, size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  tipoDispositivo,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ESTADO: ERROR ─────────────────────────────────────────────────
  Widget _buildEstadoError(String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la categoría.\nVerifica tu conexión.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── ESTADO: SIN RESULTADOS ────────────────────────────────────────
  Widget _buildSinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals, size: 72,
              color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'No hay recetas en "${widget.categoria}"',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
