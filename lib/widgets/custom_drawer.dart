import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/category_screen.dart';

// Menú lateral de navegación con categorías
class CustomDrawer extends StatelessWidget {
  // Índice de la tab activa para resaltar la sección correcta
  final int tabActiva;
  // Callback para cambiar la tab desde el drawer
  final Function(int) onTabSeleccionada;

  const CustomDrawer({
    super.key,
    required this.tabActiva,
    required this.onTabSeleccionada,
  });

  // Categorías con su ícono emoji (datos reales vendrán de la API en Clase 09)
  static const List<Map<String, String>> _categorias = [
    {'nombre': 'Chicken',    'emoji': '🍗'},
    {'nombre': 'Beef',       'emoji': '🥩'},
    {'nombre': 'Seafood',    'emoji': '🦐'},
    {'nombre': 'Vegetarian', 'emoji': '🥗'},
    {'nombre': 'Dessert',    'emoji': '🍰'},
    {'nombre': 'Pasta',      'emoji': '🍝'},
    {'nombre': 'Pork',       'emoji': '🥓'},
    {'nombre': 'Lamb',       'emoji': '🍖'},
    {'nombre': 'Breakfast',  'emoji': '🍳'},
    {'nombre': 'Side',       'emoji': '🍚'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Color de fondo del drawer
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── ENCABEZADO DEL DRAWER ────────────────────────────
          _buildHeader(),

          // ── SECCIÓN: NAVEGACIÓN PRINCIPAL ────────────────────
          _buildNavPrincipal(context),

          // ── DIVISOR ──────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: AppColors.grey200),
          ),

          // ── TÍTULO DE CATEGORÍAS ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.category, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'CATEGORÍAS',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // ── LISTA DE CATEGORÍAS (con scroll) ─────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                return _buildCategoriaItem(
                  context: context,
                  nombre: _categorias[index]['nombre']!,
                  emoji: _categorias[index]['emoji']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── ENCABEZADO: logo y nombre de la app ──────────────────────────
  Widget _buildHeader() {
    return DrawerHeader(
      // DrawerHeader ocupa el área superior del Drawer
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Ícono de la app
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restaurant_menu,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          // Nombre
          const Text(
            'CocinaApp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Subtítulo
          const Text(
            'Recetario Inteligente',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── NAVEGACIÓN PRINCIPAL: Inicio, Buscar, Favoritos ──────────────
  Widget _buildNavPrincipal(BuildContext context) {
    final opciones = [
      {'label': 'Inicio',     'icon': Icons.home_rounded,       'tab': 0},
      {'label': 'Buscar',     'icon': Icons.search_rounded,     'tab': 1},
      {'label': 'Favoritas',  'icon': Icons.favorite_rounded,   'tab': 2},
    ];

    return Column(
      children: opciones.map((opcion) {
        final tab     = opcion['tab'] as int;
        final activa  = tabActiva == tab;

        return ListTile(
          leading: Icon(
            opcion['icon'] as IconData,
            // El ícono de la tab activa se pinta con el color principal
            color: activa ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          title: Text(
            opcion['label'] as String,
            style: AppTextStyles.bodyMedium.copyWith(
              color: activa ? AppColors.primary : AppColors.textPrimary,
              fontWeight: activa ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          // Fondo resaltado para la opción activa
          tileColor: activa ? AppColors.primaryLight : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            // Cierra el drawer
            Navigator.pop(context);
            // Cambia la tab activa
            onTabSeleccionada(tab);
          },
        );
      }).toList(),
    );
  }

  // ── ÍTEM DE CATEGORÍA ────────────────────────────────────────────
  Widget _buildCategoriaItem({
    required BuildContext context,
    required String nombre,
    required String emoji,
  }) {
    return ListTile(
      // Emoji como ícono visual
      leading: Text(emoji, style: const TextStyle(fontSize: 22)),
      title: Text(nombre, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right,
          size: 18, color: AppColors.textHint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () {
        // Cierra el Drawer
        Navigator.pop(context);
        // Navigator.push: navega a CategoryScreen pasando el nombre de la categoría
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(categoria: nombre),
          ),
        );
      },
    );
  }
}
