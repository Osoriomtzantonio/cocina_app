import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

// Pantalla de recetas filtradas por categoría
// Los datos reales de la API se conectan en Clase 09
class CategoryScreen extends StatelessWidget {
  // Nombre de la categoría seleccionada desde el Drawer
  final String categoria;

  const CategoryScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo mientras no hay API real
    final recetasEjemplo = [
      {
        'nombre': 'Teriyaki Chicken Casserole',
        'area': 'Japanese',
        'imagen': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      },
      {
        'nombre': 'Chicken Handi',
        'area': 'Indian',
        'imagen': 'https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg',
      },
      {
        'nombre': 'Chicken Congee',
        'area': 'Chinese',
        'imagen': 'https://www.themealdb.com/images/media/meals/1529446352.jpg',
      },
      {
        'nombre': 'Chicken Fajita Mac',
        'area': 'American',
        'imagen': 'https://www.themealdb.com/images/media/meals/qrqywr1503066605.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // El título muestra el nombre de la categoría seleccionada
        title: Text(categoria),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ENCABEZADO de la sección ──────────────────────────
          _buildEncabezado(recetasEjemplo.length),
          // ── GRID de recetas ───────────────────────────────────
          Expanded(
            child: _buildGrid(context, recetasEjemplo),
          ),
        ],
      ),
    );
  }

  // ── ENCABEZADO: total de recetas encontradas ─────────────────────
  Widget _buildEncabezado(int total) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(
            '$total recetas encontradas',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── GRID de tarjetas de recetas ──────────────────────────────────
  Widget _buildGrid(BuildContext context, List<Map<String, String>> recetas) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,      // 2 columnas
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: recetas.length,
      itemBuilder: (context, index) {
        final receta = recetas[index];
        return RecipeCard(
          nombre: receta['nombre']!,
          categoria: categoria,
          area: receta['area']!,
          imagenUrl: receta['imagen']!,
          onTap: () {
            // Navigator.push: navega a una nueva pantalla apilándola
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(
                  idMeal: index.toString(),
                  nombre: receta['nombre']!,
                  imagenUrl: receta['imagen']!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
