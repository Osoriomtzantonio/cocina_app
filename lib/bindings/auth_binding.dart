import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 13 — AuthBinding
// ══════════════════════════════════════════════════════════════
//
// Registra el AuthController como dependencia global.
// Se añade a AppBinding para que esté disponible en toda la app,
// incluyendo el CustomDrawer y las pantallas de login/registro.

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );
  }
}
