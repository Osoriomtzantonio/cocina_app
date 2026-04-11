import 'package:flutter/material.dart';
import '../bindings/home_binding.dart';     // Clase 12
import '../bindings/busqueda_binding.dart'; // Clase 12
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart' show FavoritesScreen, FavoritesScreenState;

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

  // Key para poder llamar cargarFavoritos() cuando el usuario entra a esa tab
  final _favoritesKey = GlobalKey<FavoritesScreenState>();

  // ── CLASE 12: registrar controllers por pantalla ────────────────
  // initState se ejecuta una sola vez cuando MainScreen se crea.
  // Llamamos a los bindings aquí para que los controllers estén
  // disponibles antes de que las pantallas los soliciten con Get.find().
  @override
  void initState() {
    super.initState();
    HomeBinding().dependencies();     // registra HomeController
    BusquedaBinding().dependencies(); // registra BusquedaController
  }

  // Cambia la tab activa al índice de Buscar
  void _irABuscar() => setState(() => _tabActiva = 1);

  // Cambia de tab y recarga favoritos si se navega a esa sección
  void _cambiarTab(int index) {
    setState(() => _tabActiva = index);
    if (index == 2) {
      // Al entrar a Favoritas, siempre recargamos para reflejar cambios recientes
      _favoritesKey.currentState?.cargarFavoritos();
    }
  }

  // Títulos de la AppBar para cada tab
  final List<String> _titulos = ['CocinaApp', 'Buscar', 'Mis favoritas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ── APP BAR ────────────────────────────────────────────────
      appBar: _buildAppBar(),

      // ── DRAWER LATERAL ─────────────────────────────────────────
      drawer: CustomDrawer(
        tabActiva: _tabActiva,
        // Callback: cuando el drawer selecciona una tab
        onTabSeleccionada: _cambiarTab,
      ),

      // ── CUERPO: muestra la pantalla de la tab activa ───────────
      // IndexedStack mantiene el estado de todas las pantallas en memoria
      // (a diferencia de if/else que destruye y recrea la pantalla)
      body: IndexedStack(
        index: _tabActiva,
        children: [
          HomeScreen(onBuscarTap: _irABuscar), // pasa callback para abrir búsqueda
          SearchScreen(),
          // GlobalKey permite llamar cargarFavoritos() al cambiar de tab
          FavoritesScreen(key: _favoritesKey),
        ],
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
      // onTap: cambia de tab y recarga favoritos si es necesario
      onTap: _cambiarTab,

      // Color del ícono e indicador de la tab seleccionada
      selectedItemColor: AppColors.primary,
      // Color de los ítems no seleccionados
      unselectedItemColor: AppColors.textSecondary,

      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor
          ?? Theme.of(context).scaffoldBackgroundColor,
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
