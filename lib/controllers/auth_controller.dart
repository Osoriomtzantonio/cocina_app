import 'package:get/get.dart';
import '../services/auth_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 13 — AuthController
// ══════════════════════════════════════════════════════════════
//
// Centraliza el estado de autenticación de la app:
//   - ¿Está el usuario logueado?
//   - ¿Cuál es su nombre y email?
//   - ¿Está cargando una petición de login/registro?
//   - ¿Hubo algún error?
//
// Al estar registrado en AppBinding, cualquier pantalla puede leer
// estos observables con Get.find<AuthController>().

class AuthController extends GetxController {
  final _auth = AuthService();

  // ── OBSERVABLES ───────────────────────────────────────────────────
  final estaLogueado    = false.obs;
  final nombreUsuario   = ''.obs;
  final emailUsuario    = ''.obs;
  final cargando        = false.obs;
  final error           = Rxn<String>();   // null = sin error

  // ── onInit: se ejecuta automáticamente al registrar el controller ─
  // Verificamos si hay una sesión guardada de una ejecución anterior
  @override
  void onInit() {
    super.onInit();
    _verificarSesionGuardada();
  }

  // ── VERIFICAR SESIÓN ──────────────────────────────────────────────
  // Lee el token y los datos del usuario desde SharedPreferences.
  // Si existe, actualiza los observables para que la UI refleje
  // que el usuario ya está logueado.
  Future<void> _verificarSesionGuardada() async {
    final logueado = await _auth.estaLogueado();
    if (!logueado) return;

    final usuario = await _auth.obtenerUsuario();
    if (usuario != null) {
      nombreUsuario.value = usuario['nombre']?.toString() ?? '';
      emailUsuario.value  = usuario['email']?.toString()  ?? '';
    }
    estaLogueado.value = true;
  }

  // ── LOGIN ──────────────────────────────────────────────────────────
  // Llama a AuthService.login() y actualiza los observables.
  // Retorna true si fue exitoso, false si hubo error.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    cargando.value = true;
    error.value    = null;

    final mensaje = await _auth.login(email: email, password: password);

    if (mensaje != null) {
      // mensaje contiene el texto del error
      error.value    = mensaje;
      cargando.value = false;
      return false;
    }

    // Login exitoso: cargamos los datos del usuario
    await _actualizarEstadoUsuario();
    cargando.value = false;
    return true;
  }

  // ── REGISTRO ──────────────────────────────────────────────────────
  Future<bool> registro({
    required String nombre,
    required String email,
    required String password,
  }) async {
    cargando.value = true;
    error.value    = null;

    final mensaje = await _auth.registro(
      nombre:   nombre,
      email:    email,
      password: password,
    );

    if (mensaje != null) {
      error.value    = mensaje;
      cargando.value = false;
      return false;
    }

    await _actualizarEstadoUsuario();
    cargando.value = false;
    return true;
  }

  // ── CERRAR SESIÓN ─────────────────────────────────────────────────
  Future<void> cerrarSesion() async {
    await _auth.cerrarSesion();
    estaLogueado.value  = false;
    nombreUsuario.value = '';
    emailUsuario.value  = '';
  }

  // ── PRIVADO: actualiza los observables tras login/registro exitoso ─
  Future<void> _actualizarEstadoUsuario() async {
    final usuario = await _auth.obtenerUsuario();
    if (usuario != null) {
      nombreUsuario.value = usuario['nombre']?.toString() ?? '';
      emailUsuario.value  = usuario['email']?.toString()  ?? '';
    }
    estaLogueado.value = true;
  }

  // ── LIMPIAR ERROR ─────────────────────────────────────────────────
  // Llamado al abrir la pantalla de login/registro para limpiar
  // cualquier error anterior
  void limpiarError() => error.value = null;
}
