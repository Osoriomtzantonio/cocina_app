import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../models/recipe_model.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_grid.dart';
import 'category_screen.dart';
import 'recipe_detail_screen.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12 — HomeScreen: Get.find en lugar de Get.put
// ══════════════════════════════════════════════════════════════
//
// Clase 11 usaba Get.put(HomeController()) — creaba la instancia aquí.
// Clase 12 usa Get.find<HomeController>()  — busca la instancia ya
// registrada por HomeBinding (que se llamó desde MainScreen.initState).
//
// ¿Por qué importa esto?
//   Get.put() en build() puede crear instancias duplicadas si
//   el widget se reconstruye. Get.find() siempre reutiliza la misma.
//
// REGLA IMPORTANTE de GetX (sigue vigente):
//   No anides Obx() dentro de otro Obx().
//   Usa UN solo Obx que lea todos los observables que necesitas.

class HomeScreen extends StatelessWidget {
  // Callback que ejecuta MainScreen para cambiar a la tab de búsqueda
  final VoidCallback? onBuscarTap;

  const HomeScreen({super.key, this.onBuscarTap});

  @override
  Widget build(BuildContext context) {
    // find<T>() busca la instancia registrada por HomeBinding
    final ctrl = Get.find<HomeController>();

    // UN SOLO Obx — lee todos los observables en este bloque
    // Cuando cualquier observable cambie, este Obx reconstruye la pantalla
    return Obx(() {
      // ── Leemos TODOS los observables aquí ──────────────────────
      final cargando      = ctrl.cargando.value;
      final error         = ctrl.error.value;
      final receta        = ctrl.recetaDia.value;
      final categorias    = ctrl.categorias.toList();
      final populares     = ctrl.populares.toList();
      final recientes     = ctrl.recientes.toList();
      final cargandoRec   = ctrl.cargandoReceta.value;

      // ── Estados ─────────────────────────────────────────────────
      if (cargando) return _buildCargando();
      if (error != null) return _buildError(error, ctrl.cargarDatos);

      // ── Contenido: pasamos valores ya resueltos (no observables) ─
      return _buildContenido(
        ctrl:           ctrl,
        receta:         receta,
        categorias:     categorias,
        populares:      populares,
        recientes:      recientes,
        cargandoReceta: cargandoRec,
        onBuscarTap:    onBuscarTap,
      );
    });
  }

  // ── CARGANDO ──────────────────────────────────────────────────────
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

  // ── ERROR ─────────────────────────────────────────────────────────
  Widget _buildError(String mensaje, VoidCallback onReintentar) {
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
              Text(mensaje,
                  style: AppTextStyles.heading3, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onReintentar,
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
  // Recibe valores ya resueltos — no lee observables directamente
  Widget _buildContenido({
    required HomeController ctrl,
    required RecipeModel? receta,
    required List<CategoryModel> categorias,
    required List<RecipeModel> populares,
    required List<RecipeModel> recientes,
    required bool cargandoReceta,
    VoidCallback? onBuscarTap,
  }) {
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
              _buildHeader(onBuscarTap: onBuscarTap),

              if (receta != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildRecetaDelDia(
                    ctrl:           ctrl,
                    receta:         receta,
                    cargandoReceta: cargandoReceta,
                  ),
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
              _buildCategorias(categorias),

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
              RecipeGrid(recetas: populares, shrinkWrap: true),

              // ── VISTAS RECIENTEMENTE ──────────────────────────────
              if (recientes.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Vistas recientemente',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333))),
                ),
                const SizedBox(height: 12),
                _buildRecientesHorizontal(recientes),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── ENCABEZADO ────────────────────────────────────────────────────
  Widget _buildHeader({VoidCallback? onBuscarTap}) {
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
          // Al tocar la barra se cambia a la tab de Buscar
          GestureDetector(
            onTap: onBuscarTap,
            child: Container(
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
          ),
        ],
      ),
    );
  }

  // ── RECETA DEL DÍA ────────────────────────────────────────────────
  Widget _buildRecetaDelDia({
    required HomeController ctrl,
    required RecipeModel receta,
    required bool cargandoReceta,
  }) {
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
              onPressed: cargandoReceta ? null : ctrl.recargarRecetaDia,
              icon: cargandoReceta
                  ? const SizedBox(
                      width: 20, height: 20,
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
            nombre:    receta.strMeal,
            subtitulo: '${receta.strCategory} · ${receta.strArea}',
            opacidad:  cargandoReceta ? 0.4 : 1.0,
          ),
        ),
      ],
    );
  }

  // ── TARJETA RECETA DEL DÍA ────────────────────────────────────────
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
                      Row(children: [
                        const Icon(Icons.category, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(subtitulo,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ]),
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
  Widget _buildCategorias(List<CategoryModel> categorias) {
    if (categorias.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length > 8 ? 8 : categorias.length,
        itemBuilder: (context, index) => _buildCategoriaChip(categorias[index]),
      ),
    );
  }

  // ── CHIP DE CATEGORÍA ─────────────────────────────────────────────
  Widget _buildCategoriaChip(CategoryModel categoria) {
    return _CategoriaChip(categoria: categoria);
  }

  // ── RECIENTES: lista horizontal de tarjetas pequeñas ─────────────
  Widget _buildRecientesHorizontal(List<RecipeModel> recientes) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recientes.length,
        itemBuilder: (context, i) => _buildRecienteCard(recientes[i]),
      ),
    );
  }

  Widget _buildRecienteCard(RecipeModel receta) {
    return GestureDetector(
      onTap: () => Get.to(() => RecipeDetailScreen(
            idMeal:    receta.idMeal,
            nombre:    receta.strMeal,
            imagenUrl: receta.strMealThumb,
          )),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16)),
              child: receta.strMealThumb.isNotEmpty
                  ? Image.network(
                      receta.strMealThumb,
                      height: 88,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 88,
                        color: const Color(0xFFFFE0CC),
                        child: const Icon(Icons.restaurant,
                            color: AppColors.primary),
                      ),
                    )
                  : Container(
                      height: 88,
                      color: const Color(0xFFFFE0CC),
                      child: const Icon(Icons.restaurant,
                          color: AppColors.primary),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Text(
                receta.strMeal,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Widget separado para animar el chip al presionar
// ══════════════════════════════════════════════════════════════
class _CategoriaChip extends StatefulWidget {
  final CategoryModel categoria;
  const _CategoriaChip({required this.categoria});

  @override
  State<_CategoriaChip> createState() => _CategoriaChipState();
}

class _CategoriaChipState extends State<_CategoriaChip> {
  double _escala = 1.0; // escala normal

  void _alPresionar(bool presionando) {
    setState(() {
      // Se achica a 0.88 al presionar, regresa a 1.0 al soltar
      _escala = presionando ? 0.88 : 1.0;
    });
  }

  void _navegar() {
    Get.to(
      () => CategoryScreen(categoria: widget.categoria.strCategory),
      // Transición tipo fadeIn al navegar
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navegar,
      onTapDown: (_) => _alPresionar(true),   // inicia animación al tocar
      onTapUp: (_) => _alPresionar(false),     // termina al soltar
      onTapCancel: () => _alPresionar(false),  // termina si cancela el gesto
      child: AnimatedScale(
        scale: _escala,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
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
                  widget.categoria.strCategoryThumb,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const Icon(
                      Icons.restaurant, color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.categoria.strCategory,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF555555)),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
