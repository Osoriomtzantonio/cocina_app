import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../utils/responsive_helper.dart';
import '../screens/recipe_detail_screen.dart';
import 'recipe_card.dart';

// Widget reutilizable: grid de recetas responsivo
// Se adapta automáticamente a celular, tablet y tablet grande
class RecipeGrid extends StatelessWidget {
  final List<RecipeModel> recetas;
  // Si es true, el grid vive dentro de un ScrollView padre (no hace scroll propio)
  final bool shrinkWrap;

  const RecipeGrid({
    super.key,
    required this.recetas,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    // ── LAYOUTBUILDER ──────────────────────────────────────────────
    // LayoutBuilder construye el widget según el ancho máximo disponible
    // del contenedor PADRE (no necesariamente toda la pantalla)
    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxWidth = ancho máximo del contenedor padre
        // Calculamos las columnas según ese ancho
        final columnas = _calcularColumnas(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.of(context).paddingHorizontal,
            vertical: 8,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,       // Columnas dinámicas según pantalla
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: recetas.length,
          itemBuilder: (context, index) {
            final receta = recetas[index];
            return RecipeCard(
              nombre:    receta.strMeal,
              categoria: receta.strCategory,
              area:      receta.strArea,
              imagenUrl: receta.strMealThumb,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(
                      idMeal:    receta.idMeal,
                      nombre:    receta.strMeal,
                      imagenUrl: receta.strMealThumb,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ── CALCULAR COLUMNAS según ancho del contenedor ─────────────────
  // LayoutBuilder nos da el ancho del padre, aquí decidimos cuántas columnas
  int _calcularColumnas(double anchoDisponible) {
    if (anchoDisponible >= 900) return 4; // Tablet grande
    if (anchoDisponible >= 600) return 3; // Tablet
    return 2;                             // Celular
  }
}
