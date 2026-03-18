import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_grid.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 11 — HomeScreen con GetX
// ══════════════════════════════════════════════════════════════
//
// Cambio respecto a Clase 09:
//   Antes: StatefulWidget con _cargando, _error, _recetaDia, _categorias...
//   Ahora: StatelessWidget — CERO variables de estado aquí
//
// Todo el estado vive en HomeController.
// La UI solo usa Obx() para reaccionar a los cambios.
//
// Get.put(HomeController()) registra el controlador la primera vez
// y lo devuelve si ya existe (no crea duplicados).

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Registramos (o recuperamos) el controlador
    final ctrl = Get.put(HomeController());

    // Obx escucha TODOS los .obs que se usen dentro del closure
    // y reconstruye el widget cuando alguno cambia
    return Obx(() {
      if (ctrl.cargando.value) return _buildCargando();
      if (ctrl.error.value != null) return _buildError(ctrl);
      return _buildContenido(ctrl);
    });
  }

  // ── PANTALLA DE CARGA ─────────────────────────────────────────────
  Widget _buildCargando() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text('Cargando recetas...',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ── PANTALLA DE ERROR ─────────────────────────────────────────────
  Widget _buildError(HomeController ctrl) {
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
              Text(ctrl.error.value!,
                  style: AppTextStyles.heading3, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                // ctrl.cargarDatos() es un Future — GetX no necesita setState
                onPressed: ctrl.cargarDatos,
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

  // ── CONTENIDO PRINCIPAL ───────────────────────────────────────────
  Widget _buildContenido(HomeController ctrl) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: ctrl.cargarDatos,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildRecetaDelDia(ctrl),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Categorías',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333))),
              ),
              const SizedBox(height: 12),
              _buildCategorias(ctrl),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recetas populares',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333))),
                    Text('Ver todas',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFFF6B35),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Obx granular: solo reconstruye este grid cuando populares cambie
              Obx(() => RecipeGrid(recetas: ctrl.populares, shrinkWrap: true)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── ENCABEZADO ────────────────────────────────────────────────────
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
          const Text('¡Hola, cocinero! 👨‍🍳',
              style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 4),
          const Text('¿Qué cocinamos hoy?',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
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
                Text('Buscar recetas...',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── RECETA DEL DÍA ────────────────────────────────────────────────
  Widget _buildRecetaDelDia(HomeController ctrl) {
    // Obx granular: solo reconstruye esta sección cuando recetaDia o cargandoReceta cambien
    return Obx(() {
      final receta = ctrl.recetaDia.value;
      if (receta == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Receta del día',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333))),
              IconButton(
                onPressed: ctrl.cargandoReceta.value
                    ? null
                    : ctrl.recargarRecetaDia,
                icon: ctrl.cargandoReceta.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Nueva receta aleatoria',
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _buildTarjetaReceta(
              key: ValueKey(receta.idMeal),
              imagenUrl: receta.strMealThumb,
              nombre: receta.strMeal,
              subtitulo: '${receta.strCategory} · ${receta.strArea}',
              opacidad: ctrl.cargandoReceta.value ? 0.4 : 1.0,
            ),
          ),
        ],
      );
    });
  }

  // ── TARJETA DE RECETA DEL DÍA ─────────────────────────────────────
  Widget _buildTarjetaReceta({
    required Key key,
    required String imagenUrl,
    required String nombre,
    required String subtitulo,
    required double opacidad,
  }) {
    return AnimatedOpacity(
      key: key,
      opacity: opacidad,
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
                  imagenUrl,
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
                      Text(nombre,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.category,
                              size: 14, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(subtitulo,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white70)),
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

  // ── CATEGORÍAS ────────────────────────────────────────────────────
  Widget _buildCategorias(HomeController ctrl) {
    // Obx granular: solo reconstruye la lista de categorías
    return Obx(() {
      if (ctrl.categorias.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: ctrl.categorias.length > 8 ? 8 : ctrl.categorias.length,
          itemBuilder: (context, index) =>
              _buildCategoriaChip(ctrl.categorias[index]),
        ),
      );
    });
  }

  // ── CHIP DE CATEGORÍA ─────────────────────────────────────────────
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              categoria.strCategoryThumb,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.restaurant, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            categoria.strCategory,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555)),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
