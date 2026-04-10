import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/busqueda_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_grid.dart';

// ══════════════════════════════════════════════════════════════
// SearchScreen — búsqueda con filtros por categoría
//
// Novedad:
//   - Chips de categoría horizontales deslizables
//   - Al tocar un chip filtra por esa categoría
//   - Combina búsqueda por texto + filtro por categoría
// ══════════════════════════════════════════════════════════════

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BusquedaController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Buscar recetas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── BARRA DE BÚSQUEDA ───────────────────────────────────
          _buildBarraBusqueda(ctrl),

          // ── CHIPS DE CATEGORÍAS ─────────────────────────────────
          Obx(() => _buildChipsCategorias(ctrl)),

          // ── CONTENIDO ───────────────────────────────────────────
          Expanded(child: Obx(() => _buildContenido(ctrl))),
        ],
      ),
    );
  }

  // ── BARRA DE BÚSQUEDA ─────────────────────────────────────────────
  Widget _buildBarraBusqueda(BusquedaController ctrl) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _textController,
          onChanged: ctrl.onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Escribe el nombre de una receta...',
            hintStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: Obx(() => ctrl.query.value.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close,
                        color: Theme.of(Get.context!).textTheme.bodySmall?.color),
                    onPressed: () {
                      _textController.clear();
                      ctrl.onQueryChanged('');
                    },
                  )
                : const SizedBox.shrink()),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── CHIPS HORIZONTALES DE CATEGORÍAS ─────────────────────────────
  Widget _buildChipsCategorias(BusquedaController ctrl) {
    if (ctrl.categorias.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Theme.of(Get.context!).cardColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: ctrl.categorias.map((cat) {
            final activa =
                ctrl.categoriaSeleccionada.value == cat.strCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => ctrl.seleccionarCategoria(cat.strCategory),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: activa ? AppColors.primary : Theme.of(Get.context!).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activa
                          ? AppColors.primary
                          : AppColors.grey200,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    cat.strCategory,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: activa
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── CONTENIDO DINÁMICO ────────────────────────────────────────────
  Widget _buildContenido(BusquedaController ctrl) {
    final hayCategoria = ctrl.categoriaSeleccionada.value != null;
    final hayQuery     = ctrl.query.value.isNotEmpty;

    if (!hayQuery && !hayCategoria) return _buildEstadoVacio();
    if (ctrl.cargando.value)        return _buildEstadoCargando(ctrl);
    if (ctrl.sinResultados.value)   return _buildSinResultados(ctrl);
    if (ctrl.resultados.isNotEmpty) return _buildResultados(ctrl);
    return _buildEstadoVacio();
  }

  // ── VACÍO ─────────────────────────────────────────────────────────
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('¿Qué quieres cocinar hoy?', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Escribe un nombre o selecciona\nuna categoría para filtrar',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Theme.of(Get.context!).textTheme.bodySmall?.color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── CARGANDO ──────────────────────────────────────────────────────
  Widget _buildEstadoCargando(BusquedaController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            ctrl.query.value.isNotEmpty
                ? 'Buscando "${ctrl.query.value}"...'
                : 'Cargando ${ctrl.categoriaSeleccionada.value ?? ""}...',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Theme.of(Get.context!).textTheme.bodySmall?.color),
          ),
        ],
      ),
    );
  }

  // ── SIN RESULTADOS ────────────────────────────────────────────────
  Widget _buildSinResultados(BusquedaController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals,
              size: 72, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            ctrl.query.value.isNotEmpty
                ? 'Sin resultados para "${ctrl.query.value}"'
                : 'Sin recetas en ${ctrl.categoriaSeleccionada.value}',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro nombre\no selecciona otra categoría',
            style: TextStyle(color: Theme.of(Get.context!).textTheme.bodySmall?.color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── RESULTADOS ────────────────────────────────────────────────────
  Widget _buildResultados(BusquedaController ctrl) {
    String etiqueta;
    if (ctrl.query.value.isNotEmpty &&
        ctrl.categoriaSeleccionada.value != null) {
      etiqueta =
          '${ctrl.resultados.length} resultado${ctrl.resultados.length != 1 ? "s" : ""} en ${ctrl.categoriaSeleccionada.value}';
    } else if (ctrl.categoriaSeleccionada.value != null) {
      etiqueta =
          '${ctrl.resultados.length} receta${ctrl.resultados.length != 1 ? "s" : ""} de ${ctrl.categoriaSeleccionada.value}';
    } else {
      etiqueta =
          '${ctrl.resultados.length} resultado${ctrl.resultados.length != 1 ? "s" : ""} para "${ctrl.query.value}"';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            etiqueta,
            style: AppTextStyles.bodyMedium
                .copyWith(color: Theme.of(Get.context!).textTheme.bodySmall?.color),
          ),
        ),
        Expanded(child: RecipeGrid(recetas: ctrl.resultados)),
      ],
    );
  }
}
