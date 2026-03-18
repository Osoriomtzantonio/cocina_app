import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';

// Pantalla contenedora principal
// Gestiona las tabs (BottomNavigationBar) y el Drawer lateral
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Índice de la tab seleccionada (0=Inicio, 1=Buscar, 2=Favoritas)
  int _tabActiva = 0;

  // Lista de pantallas que corresponden a cada tab
  // Se crean una sola vez y se mantienen en memoria al cambiar de tab
  final List<Widget> _pantallas = [
    const HomeScreen(),
    SearchScreen(),        // no const: tiene TextEditingController interno
    const FavoritesScreen(),
  ];

  // Títulos de la AppBar para cada tab
  final List<String> _titulos = ['CocinaApp', 'Buscar', 'Mis favoritas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ── APP BAR ────────────────────────────────────────────────
      appBar: _buildAppBar(),

      // ── DRAWER LATERAL ─────────────────────────────────────────
      drawer: CustomDrawer(
        tabActiva: _tabActiva,
        // Callback: cuando el drawer selecciona una tab
        onTabSeleccionada: (index) {
          setState(() => _tabActiva = index);
        },
      ),

      // ── CUERPO: muestra la pantalla de la tab activa ───────────
      // IndexedStack mantiene el estado de todas las pantallas en memoria
      // (a diferencia de if/else que destruye y recrea la pantalla)
      body: IndexedStack(
        index: _tabActiva,
        children: _pantallas,
      ),

      // ── BOTTOM NAVIGATION BAR ───────────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      // El título cambia según la tab activa
      title: Text(_titulos[_tabActiva]),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      // El ícono de menú (hamburguesa) abre el Drawer automáticamente
      // Flutter lo agrega automáticamente cuando hay un Drawer en el Scaffold
    );
  }

  // ── BOTTOM NAVIGATION BAR ────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      // Índice de la tab actualmente seleccionada
      currentIndex: _tabActiva,
      // onTap: se ejecuta cuando el usuario toca una tab
      onTap: (index) => setState(() => _tabActiva = index),

      // Color del ícono e indicador de la tab seleccionada
      selectedItemColor: AppColors.primary,
      // Color de los ítems no seleccionados
      unselectedItemColor: AppColors.textSecondary,

      backgroundColor: Colors.white,
      // fixed: todas las tabs tienen el mismo ancho
      type: BottomNavigationBarType.fixed,
      elevation: 8,

      // Estilos de texto para tabs seleccionadas y no seleccionadas
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 11),

      // ── TABS ────────────────────────────────────────────────────
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded), // Ícono relleno cuando está activa
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search_rounded),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite_rounded),
          label: 'Favoritas',
        ),
      ],
    );
  }
}
