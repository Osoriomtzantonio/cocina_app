import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/busqueda_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_grid.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 11 — SearchScreen con GetX
// ══════════════════════════════════════════════════════════════
//
// Cambio respecto a Clase 09:
//   Antes: StatefulWidget con Timer, TextEditingController, setState...
//   Ahora: StatelessWidget — toda la lógica está en BusquedaController
//
// El TextEditingController sigue aquí porque es un controlador de UI
// (maneja el campo de texto), no de estado de negocio.

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  // TextEditingController es de UI — va en la pantalla, no en el controller
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BusquedaController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buscar recetas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildBarraBusqueda(ctrl),
          // Obx escucha query, cargando, resultados y sinResultados
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
          // Delegamos el manejo al BusquedaController
          onChanged: ctrl.onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Escribe el nombre de una receta...',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            // Obx para el botón X — solo se reconstruye este pequeño widget
            suffixIcon: Obx(() => ctrl.query.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary),
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

  // ── CONTENIDO DINÁMICO ────────────────────────────────────────────
  // Este método se llama dentro de Obx(), por eso NO necesita ser un widget
  Widget _buildContenido(BusquedaController ctrl) {
    if (ctrl.query.value.isEmpty)   return _buildEstadoVacio();
    if (ctrl.cargando.value)        return _buildEstadoCargando(ctrl);
    if (ctrl.sinResultados.value)   return _buildSinResultados(ctrl);
    if (ctrl.resultados.isNotEmpty) return _buildResultados(ctrl);
    return _buildEstadoVacio();
  }

  // ── ESTADO: CAMPO VACÍO ───────────────────────────────────────────
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
            'Escribe el nombre de una receta\npara comenzar a buscar',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── ESTADO: CARGANDO ─────────────────────────────────────────────
  Widget _buildEstadoCargando(BusquedaController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Buscando "${ctrl.query.value}"...',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── ESTADO: SIN RESULTADOS ────────────────────────────────────────
  Widget _buildSinResultados(BusquedaController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals,
              size: 72, color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Sin resultados para "${ctrl.query.value}"',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro nombre\no revisa la ortografía',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── ESTADO: RESULTADOS ────────────────────────────────────────────
  Widget _buildResultados(BusquedaController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            '${ctrl.resultados.length} resultado${ctrl.resultados.length != 1 ? "s" : ""} para "${ctrl.query.value}"',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(child: RecipeGrid(recetas: ctrl.resultados)),
      ],
    );
  }
}
