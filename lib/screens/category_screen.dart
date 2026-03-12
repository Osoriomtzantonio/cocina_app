import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../utils/responsive_helper.dart';
import '../widgets/recipe_grid.dart';

// Pantalla de recetas filtradas por categoría — con diseño RESPONSIVE
// Los datos reales de la API se conectan en Clase 09
class CategoryScreen extends StatelessWidget {
  final String categoria;

  const CategoryScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    // ── MEDIAQUERY: obtenemos info de la pantalla ─────────────────
    // responsive tiene propiedades como esCelular, esTablet, columnasGrid, etc.
    final responsive = ResponsiveHelper.of(context);

    // Datos de ejemplo (vendrán de la API en Clase 09)
    final recetas = [
      RecipeModel(idMeal: '52772', strMeal: 'Teriyaki Chicken Casserole',
          strCategory: categoria, strArea: 'Japanese', strInstructions: '',
          ingredientes: [], strMealThumb: 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg'),
      RecipeModel(idMeal: '52795', strMeal: 'Chicken Handi',
          strCategory: categoria, strArea: 'Indian', strInstructions: '',
          ingredientes: [], strMealThumb: 'https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg'),
      RecipeModel(idMeal: '52956', strMeal: 'Chicken Congee',
          strCategory: categoria, strArea: 'Chinese', strInstructions: '',
          ingredientes: [], strMealThumb: 'https://www.themealdb.com/images/media/meals/1529446352.jpg'),
      RecipeModel(idMeal: '52993', strMeal: 'Chicken Fajita Mac',
          strCategory: categoria, strArea: 'American', strInstructions: '',
          ingredientes: [], strMealThumb: 'https://www.themealdb.com/images/media/meals/qrqywr1503066605.jpg'),
      RecipeModel(idMeal: '52821', strMeal: 'Chicken Marengo',
          strCategory: categoria, strArea: 'French', strInstructions: '',
          ingredientes: [], strMealThumb: 'https://www.themealdb.com/images/media/meals/qpxvuq1511798906.jpg'),
      RecipeModel(idMeal: '52940', strMeal: 'Brown Stew Chicken',
          strCategory: categoria, strArea: 'Jamaican', strInstructions: '',
          ingredientes: [], strMealThumb: 'https://www.themealdb.com/images/media/meals/sypxpx1515365095.jpg'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          categoria,
          // ── MEDIAQUERY en acción: el título es más grande en tablets
          style: TextStyle(fontSize: responsive.fontSizeTitulo),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ENCABEZADO responsive ─────────────────────────────
          _buildEncabezado(recetas.length, responsive),
          // ── GRID RESPONSIVE (usa RecipeGrid con LayoutBuilder) ─
          Expanded(
            child: RecipeGrid(recetas: recetas),
          ),
        ],
      ),
    );
  }

  // ── ENCABEZADO: muestra el tipo de dispositivo detectado ─────────
  Widget _buildEncabezado(int total, ResponsiveHelper responsive) {
    // Texto que muestra el tipo de pantalla detectado (útil para demostración)
    final tipoDispositivo = responsive.esTabletGrande
        ? 'Tablet grande (4 cols)'
        : responsive.esTablet
            ? 'Tablet (3 cols)'
            : responsive.esHorizontal
                ? 'Horizontal (3 cols)'
                : 'Celular (2 cols)';

    return Container(
      color: AppColors.primary,
      // ── MEDIAQUERY: padding horizontal adaptable ──────────────
      padding: EdgeInsets.fromLTRB(
          responsive.paddingHorizontal, 0, responsive.paddingHorizontal, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total de recetas
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
          // Tipo de dispositivo detectado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  // Ícono diferente según el dispositivo
                  responsive.esCelular
                      ? Icons.smartphone
                      : Icons.tablet_mac,
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
}
