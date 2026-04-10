import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 13 — RegisterScreen
// ══════════════════════════════════════════════════════════════
//
// Similar a LoginScreen pero con tres campos: nombre, email, password.
// Añade un campo "Confirmar contraseña" para validar que ambas
// contraseñas coincidan antes de enviar al servidor.
//
// Get.off() vs Get.back():
//   Get.back() → regresa a la pantalla anterior (LoginScreen)
//   Get.off()  → reemplaza la pantalla actual (no añade al historial)
//   Aquí usamos Get.off(LoginScreen) para que al registrarse
//   el usuario no tenga que presionar "atrás" dos veces.

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _nombreCtrl      = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmarCtrl   = TextEditingController();

  bool _verPassword      = false;
  bool _verConfirmar     = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.limpiarError());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // ── TÍTULO ──────────────────────────────────────────────
            Text(
              'Únete a CocinaApp',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu cuenta para guardar recetas favoritas',
              style: AppTextStyles.bodySmall
                  .copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ── FORMULARIO ──────────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── NOMBRE ────────────────────────────────────────
                  TextFormField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      label: 'Nombre completo',
                      icono: Icons.person_outline,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu nombre';
                      }
                      if (valor.trim().length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── EMAIL ─────────────────────────────────────────
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      label: 'Correo electrónico',
                      icono: Icons.email_outlined,
                    ),
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!valor.contains('@') || !valor.contains('.')) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── CONTRASEÑA ────────────────────────────────────
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: !_verPassword,
                    decoration: _inputDecoration(
                      label: 'Contraseña',
                      icono: Icons.lock_outline,
                    ).copyWith(
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
                        return 'Ingresa una contraseña';
                      }
                      if (valor.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── CONFIRMAR CONTRASEÑA ──────────────────────────
                  TextFormField(
                    controller: _confirmarCtrl,
                    obscureText: !_verConfirmar,
                    decoration: _inputDecoration(
                      label: 'Confirmar contraseña',
                      icono: Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _verConfirmar
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        onPressed: () =>
                            setState(() => _verConfirmar = !_verConfirmar),
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Confirma tu contraseña';
                      }
                      // Comparamos con el campo de contraseña
                      if (valor != _passwordCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── MENSAJE DE ERROR ─────────────────────────────────────
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

            // ── BOTÓN REGISTRARSE ────────────────────────────────────
            Obx(() {
              final cargando = ctrl.cargando.value;
              return ElevatedButton(
                onPressed: cargando ? null : () => _enviarRegistro(ctrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.6),
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
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            }),
            const SizedBox(height: 20),

            // ── ENLACE A LOGIN ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Ya tienes cuenta? ',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                GestureDetector(
                  // Get.back() regresa a LoginScreen
                  onTap: () => Get.back(),
                  child: Text(
                    'Inicia sesión',
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
  Future<void> _enviarRegistro(AuthController ctrl) async {
    if (!_formKey.currentState!.validate()) return;

    final exito = await ctrl.registro(
      nombre:   _nombreCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    // Si el registro fue exitoso, cerramos la pantalla (y LoginScreen)
    // y volvemos al drawer de MainScreen
    if (exito) Get.back();
  }

  // ── HELPER ───────────────────────────────────────────────────────
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
