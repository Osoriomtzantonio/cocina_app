import 'package:flutter/material.dart';
import '../bindings/home_binding.dart';
import '../bindings/busqueda_binding.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_drawer.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart' show FavoritesScreen, FavoritesScreenState;

// ══════════════════════════════════════════════════════════════
// MainScreen con navegadores anidados por tab
//
// Cada tab tiene su propio Navigator. Cuando el usuario abre
// RecipeDetailScreen desde cualquier tab, el push ocurre DENTRO
// de ese Navigator, por lo que la barra inferior (BottomNav)
// permanece visible en todo momento.
// ══════════════════════════════════════════════════════════════

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tabActiva = 0;

  // Key del Scaffold para abrir el Drawer desde pantallas hijas
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Key para recargar favoritos al entrar a esa tab
  final _favoritesKey = GlobalKey<FavoritesScreenState>();

  // Un Navigator independiente por cada tab.
  // Esto permite navegar dentro de la tab sin ocultar el BottomNav.
  final List<GlobalKey<NavigatorState>> _navKeys = [
    GlobalKey<NavigatorState>(), // Tab 0 — Inicio
    GlobalKey<NavigatorState>(), // Tab 1 — Buscar
    GlobalKey<NavigatorState>(), // Tab 2 — Favoritas
  ];

  @override
  void initState() {
    super.initState();
    HomeBinding().dependencies();
    BusquedaBinding().dependencies();
  }

  // ── CAMBIO DE TAB ──────────────────────────────────────────────────
  void _cambiarTab(int index) {
    if (_tabActiva == index) {
      // Toca la tab activa → vuelve a la pantalla raíz de esa tab
      _navKeys[index].currentState?.popUntil((r) => r.isFirst);
    } else {
      setState(() => _tabActiva = index);
      if (index == 2) {
        // Espera un frame para que el Navigator esté montado antes de recargar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _favoritesKey.currentState?.cargarFavoritos();
        });
      }
    }
  }

  // Abre el Drawer lateral desde cualquier pantalla hija
  void _abrirDrawer() => _scaffoldKey.currentState?.openDrawer();

  // ── BOTÓN ATRÁS DEL SISTEMA ────────────────────────────────────────
  // Si el tab activo tiene historial → hace pop dentro del Navigator.
  // Si ya está en la raíz y no es Inicio → vuelve a Inicio.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop =
            await _navKeys[_tabActiva].currentState?.maybePop() ?? false;
        if (!canPop && _tabActiva != 0) _cambiarTab(0);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // ── DRAWER LATERAL ──────────────────────────────────────────
        drawer: CustomDrawer(
          tabActiva: _tabActiva,
          onTabSeleccionada: _cambiarTab,
        ),

        // ── CUERPO: un Navigator por tab ────────────────────────────
        // Offstage mantiene los navegadores montados en memoria aunque
        // no estén visibles, conservando el estado de cada tab.
        body: Stack(
          children: [
            _buildTab(
              0,
              HomeScreen(
                onBuscarTap: () => _cambiarTab(1),
                onMenuTap: _abrirDrawer,
              ),
            ),
            _buildTab(1, SearchScreen()),
            _buildTab(2, FavoritesScreen(key: _favoritesKey)),
          ],
        ),

        // ── BOTTOM NAVIGATION BAR ───────────────────────────────────
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // Construye un tab con su propio Navigator aislado
  Widget _buildTab(int index, Widget screen) {
    return Offstage(
      offstage: _tabActiva != index,
      child: Navigator(
        key: _navKeys[index],
        // La ruta raíz de cada tab es la pantalla principal del tab
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => screen),
      ),
    );
  }

  // ── BOTTOM NAVIGATION BAR ─────────────────────────────────────────
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _tabActiva,
      onTap: _cambiarTab,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
              Theme.of(context).scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
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
