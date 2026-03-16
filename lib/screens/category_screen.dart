import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../utils/responsive_helper.dart';
import '../widgets/recipe_grid.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 09 — CategoryScreen conectada a la API real
// ══════════════════════════════════════════════════════════════
//
// Cambio respecto a Clase 07:
//   Antes: StatelessWidget con datos hardcodeados
//   Ahora: StatefulWidget que llama a la API en initState()
//
// Nota: el endpoint filter.php devuelve datos SIMPLIFICADOS
//   (solo idMeal, strMeal, strMealThumb — sin ingredientes ni instrucciones)
//   El detalle completo lo carga RecipeDetailScreen al abrir cada receta.

class CategoryScreen extends StatefulWidget {
  final String categoria;

  const CategoryScreen({super.key, required this.categoria});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ApiService _api = ApiService();

  // Estados de la pantalla
  bool _cargando = true;
  String? _error;
  List<RecipeModel> _recetas = [];

  @override
  void initState() {
    super.initState();
    // Cargamos las recetas de esta categoría al crear la pantalla
    _cargarRecetas();
  }

  Future<void> _cargarRecetas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    // await espera la respuesta del endpoint filter.php
    final resultado = await _api.obtenerRecetasPorCategoria(widget.categoria);

    if (!mounted) return;

    if (resultado.isEmpty) {
      setState(() {
        _cargando = false;
        _error = 'No se encontraron recetas para "${widget.categoria}"';
      });
      return;
    }

    setState(() {
      _cargando = false;
      // copyWith: inyectamos el nombre de la categoría en cada receta
      // porque filter.php no lo incluye (datos simplificados)
      _recetas = resultado
          .map((r) => r.copyWith(strCategory: widget.categoria))
          .toList();
    });
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEncabezado(responsive),
          Expanded(child: _buildContenido()),
        ],
      ),
    );
  }

  // ── ENCABEZADO ────────────────────────────────────────────────────
  Widget _buildEncabezado(ResponsiveHelper responsive) {
    final tipoDispositivo = responsive.esTabletGrande
        ? 'Tablet grande (4 cols)'
        : responsive.esTablet
            ? 'Tablet (3 cols)'
            : responsive.esHorizontal
                ? 'Horizontal (3 cols)'
                : 'Celular (2 cols)';

    final total = _cargando ? '...' : '${_recetas.length}';

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
                  color: Colors.white,
                  size: 13,
                ),
                const SizedBox(width: 4),
                Text(
                  tipoDispositivo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CONTENIDO CENTRAL ─────────────────────────────────────────────
  Widget _buildContenido() {
    // Estado: cargando
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Estado: error
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargarRecetas,
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
      );
    }

    // Estado: datos cargados — mostramos el grid responsive
    return RecipeGrid(recetas: _recetas);
  }
}
