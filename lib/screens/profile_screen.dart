import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

// ══════════════════════════════════════════════════════════════
// ProfileScreen — muestra datos del usuario y opciones de sesión
// ══════════════════════════════════════════════════════════════

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final logueado = authCtrl.estaLogueado.value;

        if (!logueado) return _buildSinSesion();

        return _buildConSesion(authCtrl);
      }),
    );
  }

  // ── USUARIO LOGUEADO ──────────────────────────────────────────────
  Widget _buildConSesion(AuthController authCtrl) {
    final nombre = authCtrl.nombreUsuario.value;
    final email  = authCtrl.emailUsuario.value;
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── ENCABEZADO NARANJA CON AVATAR ──────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Avatar con inicial
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── TARJETA DE INFORMACIÓN ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoItem(Icons.person_outline, 'Nombre', nombre),
                  const Divider(height: 1, indent: 56),
                  _buildInfoItem(Icons.email_outlined, 'Correo', email),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── BOTÓN CERRAR SESIÓN ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmarCerrarSesion(authCtrl),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── FILA DE DATO DEL USUARIO ──────────────────────────────────────
  Widget _buildInfoItem(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icono, color: AppColors.primary, size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(etiqueta,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(valor,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // ── SIN SESIÓN ────────────────────────────────────────────────────
  Widget _buildSinSesion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined,
                size: 80, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('No has iniciado sesión',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Inicia sesión para ver\ntu perfil y gestionar recetas',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const LoginScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Iniciar sesión',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const RegisterScreen()),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Crear cuenta',
                    style: TextStyle(color: AppColors.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CONFIRMACIÓN ANTES DE CERRAR SESIÓN ──────────────────────────
  void _confirmarCerrarSesion(AuthController authCtrl) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              authCtrl.cerrarSesion();
            },
            child: Text('Cerrar sesión',
                style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }
}
