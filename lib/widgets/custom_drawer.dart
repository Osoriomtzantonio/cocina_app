import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../screens/category_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/mis_recetas_screen.dart';
import '../screens/shopping_list_screen.dart';

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

  // Categorías con su ícono emoji — nombres en español igual que el backend/seed
  static const List<Map<String, String>> _categorias = [
    {'nombre': 'Pollo',        'emoji': '🍗'},
    {'nombre': 'Res',          'emoji': '🥩'},
    {'nombre': 'Mariscos',     'emoji': '🦐'},
    {'nombre': 'Vegetariano',  'emoji': '🥗'},
    {'nombre': 'Postres',      'emoji': '🍰'},
    {'nombre': 'Sopas',        'emoji': '🍲'},
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── ENCABEZADO DEL DRAWER ────────────────────────────
          _buildHeader(context),

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

          // ── BOTÓN DE SESIÓN ───────────────────────────────────
          _buildBotonSesion(context),
        ],
      ),
    );
  }

  // ── ENCABEZADO: logo o datos del usuario ─────────────────────────
  // ══════════════════════════════════════════════════════════════════
  // CLASE 13 — Drawer reactivo con Obx
  // ══════════════════════════════════════════════════════════════════
  //
  // Obx() permite que el DrawerHeader reaccione automáticamente
  // cuando el usuario inicia o cierra sesión, sin reconstruir
  // toda la pantalla.
  //
  // Si está logueado  → muestra avatar con inicial + nombre + email
  // Si no está logueado → muestra ícono de app + botón "Iniciar sesión"
  Widget _buildHeader(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      final logueado = authCtrl.estaLogueado.value;
      final nombre   = authCtrl.nombreUsuario.value;
      final email    = authCtrl.emailUsuario.value;

      return DrawerHeader(
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
            if (logueado) ...[
              // ── USUARIO LOGUEADO: avatar con inicial ────────────
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: Text(
                  // Primera letra del nombre en mayúscula
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                email,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ] else ...[
              // ── SIN SESIÓN: ícono de app ─────────────────────────
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
              const Text(
                'CocinaApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Recetario Inteligente',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ],
        ),
      );
    });
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

  // ── BOTÓN DE SESIÓN (parte inferior del drawer) ──────────────────
  // Si el usuario está logueado → botón "Cerrar sesión"
  // Si no está logueado → botón "Iniciar sesión"
  Widget _buildBotonSesion(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Obx(() {
      final logueado = authCtrl.estaLogueado.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          children: [
            const Divider(color: AppColors.grey200),
            const SizedBox(height: 4),

            // ── OPCIONES SOLO PARA USUARIOS LOGUEADOS ─────────────
            if (logueado) ...[
              ListTile(
                leading: const Icon(Icons.person_outline,
                    color: AppColors.primary),
                title: Text('Mi perfil',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const ProfileScreen(),
                      transition: Transition.rightToLeft);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined,
                    color: AppColors.primary),
                title: Text('Mis recetas',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => const MisRecetasScreen(),
                      transition: Transition.rightToLeft);
                },
              ),
              const SizedBox(height: 4),
            ],

            // ── LISTA DE COMPRAS (visible para todos) ──────────────
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined,
                  color: AppColors.primary),
              title: Text('Lista de compras',
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const ShoppingListScreen(),
                    transition: Transition.rightToLeft);
              },
            ),
            const SizedBox(height: 4),

            ListTile(
              leading: Icon(
                logueado ? Icons.logout : Icons.login,
                color: logueado ? Colors.red.shade400 : AppColors.primary,
              ),
              title: Text(
                logueado ? 'Cerrar sesión' : 'Iniciar sesión',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: logueado ? Colors.red.shade400 : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context); // cierra el drawer

                if (logueado) {
                  // Confirmación antes de cerrar sesión
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text(
                          '¿Estás seguro de que quieres cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back(); // cierra el diálogo
                            authCtrl.cerrarSesion();
                          },
                          child: Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red.shade400),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Navega a la pantalla de login
                  Get.to(() => const LoginScreen());
                }
              },
            ),
          ],
        ),
      );
    });
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
