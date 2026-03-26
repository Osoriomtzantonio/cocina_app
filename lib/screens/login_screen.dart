import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 13 — LoginScreen
// ══════════════════════════════════════════════════════════════
//
// Conceptos nuevos en esta pantalla:
//
// Form + GlobalKey<FormState>:
//   Form agrupa varios TextFormField y permite validarlos todos
//   a la vez con _formKey.currentState!.validate()
//
// TextFormField vs TextField:
//   TextField → campo simple, sin validación incorporada
//   TextFormField → campo dentro de un Form, con validator
//
// validator:
//   Función que recibe el valor del campo y devuelve:
//     null      → el campo es válido
//     'mensaje' → el campo es inválido (muestra el mensaje en rojo)
//
// obscureText: true → oculta el texto (para contraseñas)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey identifica al Form y permite llamar .validate() desde fuera
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para leer los valores al enviar
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Estado local de UI: mostrar/ocultar contraseña
  bool _verPassword = false;

  @override
  void dispose() {
    // Siempre liberar los TextEditingController en dispose()
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();

    // Limpiamos errores previos al entrar a la pantalla
    // addPostFrameCallback: espera a que el frame se dibuje antes de ejecutar
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.limpiarError());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),

            // ── ÍCONO SUPERIOR ──────────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── TÍTULO ──────────────────────────────────────────────
            Text(
              'Bienvenido de vuelta',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia sesión para acceder a tus recetas favoritas',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // ── FORMULARIO ──────────────────────────────────────────
            // Form agrupa los TextFormField para validarlos en conjunto
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── EMAIL ─────────────────────────────────────────
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      label: 'Correo electrónico',
                      icono: Icons.email_outlined,
                    ),
                    // validator se llama al hacer _formKey.currentState!.validate()
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!valor.contains('@')) {
                        return 'Ingresa un correo válido';
                      }
                      return null; // válido
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── CONTRASEÑA ────────────────────────────────────
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_verPassword, // oculta el texto si es false
                    decoration: _inputDecoration(
                      label: 'Contraseña',
                      icono: Icons.lock_outline,
                    ).copyWith(
                      // suffixIcon: botón para mostrar/ocultar la contraseña
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        onPressed: () =>
                            setState(() => _verPassword = !_verPassword),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      if (valor.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── MENSAJE DE ERROR (del servidor) ─────────────────────
            // Obx reacciona cuando ctrl.error cambia
            Obx(() {
              final msg = ctrl.error.value;
              if (msg == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg,
                        style: TextStyle(
                            color: Colors.red.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // ── BOTÓN INICIAR SESIÓN ─────────────────────────────────
            Obx(() {
              final cargando = ctrl.cargando.value;
              return ElevatedButton(
                onPressed: cargando ? null : () => _enviarLogin(ctrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                ),
                child: cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            }),
            const SizedBox(height: 20),

            // ── ENLACE A REGISTRO ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿No tienes cuenta? ',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                GestureDetector(
                  onTap: () => Get.off(() => const RegisterScreen()),
                  child: Text(
                    'Regístrate',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── LÓGICA DE ENVÍO ───────────────────────────────────────────────
  Future<void> _enviarLogin(AuthController ctrl) async {
    // validate() ejecuta todos los validators del Form
    // Si alguno devuelve un mensaje (no null), retorna false
    if (!_formKey.currentState!.validate()) return;

    final exito = await ctrl.login(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    // Si el login fue exitoso, cerramos la pantalla y volvemos al drawer
    if (exito) Get.back();
  }

  // ── HELPER: decoración reutilizable para los campos ──────────────
  InputDecoration _inputDecoration({
    required String label,
    required IconData icono,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: Theme.of(context).textTheme.bodySmall?.color),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.grey200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }
}
