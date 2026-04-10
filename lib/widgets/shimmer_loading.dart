import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ══════════════════════════════════════════════════════════════
// ShimmerLoading — widgets skeleton animados para estados de carga
//
// En vez de mostrar un CircularProgressIndicator aburrido,
// mostramos placeholders con animación shimmer (brillo que
// recorre la forma) como Instagram, YouTube, etc.
// ══════════════════════════════════════════════════════════════

class ShimmerLoading {
  ShimmerLoading._();

  // ── COLOR BASE según tema ───────────────────────────────────────
  static Color _base(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFE0E0E0);

  static Color _highlight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3A3A3A)
          : const Color(0xFFF5F5F5);

  // ── SHIMMER WRAPPER ─────────────────────────────────────────────
  static Widget _shimmer(BuildContext context, {required Widget child}) {
    return Shimmer.fromColors(
      baseColor: _base(context),
      highlightColor: _highlight(context),
      child: child,
    );
  }

  // ── CAJA REDONDEADA (bloque genérico) ───────────────────────────
  static Widget box({
    double width = double.infinity,
    double height = 16,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SKELETONS PREDISEÑADOS
  // ══════════════════════════════════════════════════════════════════

  // ── SKELETON: tarjeta de receta (para RecipeGrid) ───────────────
  static Widget recipeCard(BuildContext context) {
    return _shimmer(
      context,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen placeholder
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            // Texto placeholder
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: 120, height: 14),
                  const SizedBox(height: 8),
                  box(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SKELETON: grid completo de recetas ───────────────────────────
  static Widget recipeGrid(BuildContext context, {int count = 4}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: count,
        itemBuilder: (context, _) => recipeCard(context),
      ),
    );
  }

  // ── SKELETON: HomeScreen completo ───────────────────────────────
  static Widget homeScreen(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          _shimmer(
            context,
            child: Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Receta del día
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _shimmer(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: 140, height: 20),
                  const SizedBox(height: 12),
                  box(height: 200, radius: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Categorías
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _shimmer(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: 120, height: 20),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: List.generate(
                        4,
                        (_) => Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recetas populares
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _shimmer(context, child: box(width: 180, height: 20)),
          ),
          const SizedBox(height: 12),
          recipeGrid(context),
        ],
      ),
    );
  }

  // ── SKELETON: detalle de receta ─────────────────────────────────
  static Widget recipeDetail(BuildContext context) {
    return _shimmer(
      context,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            box(width: 200, height: 24),
            const SizedBox(height: 16),
            // Badges
            Row(
              children: [
                box(width: 100, height: 30, radius: 20),
                const SizedBox(width: 10),
                box(width: 80, height: 30, radius: 20),
              ],
            ),
            const SizedBox(height: 24),
            // Ingredientes
            box(width: 130, height: 20),
            const SizedBox(height: 14),
            ...List.generate(6, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  box(width: 8, height: 8, radius: 4),
                  const SizedBox(width: 12),
                  Expanded(child: box(height: 14)),
                  const SizedBox(width: 20),
                  box(width: 50, height: 14),
                ],
              ),
            )),
            const SizedBox(height: 24),
            // Instrucciones
            box(width: 150, height: 20),
            const SizedBox(height: 14),
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: box(height: 14),
            )),
          ],
        ),
      ),
    );
  }

  // ── SKELETON: lista horizontal de recientes ─────────────────────
  static Widget horizontalCards(BuildContext context, {int count = 3}) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        itemBuilder: (_, __) => _shimmer(
          context,
          child: Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
