import 'package:get/get.dart';
import '../repositories/recetas_repository.dart';
import '../datasources/recetas_datasource.dart';
import '../controllers/auth_controller.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12/13 — AppBinding (dependencias globales)
// ══════════════════════════════════════════════════════════════
//
// AppBinding se ejecuta UNA VEZ al iniciar la app (en main.dart).
// Registra las dependencias que necesitan estar disponibles
// durante toda la vida de la aplicación.
//
// Clase 12 añadió: RecetasRepository
// Clase 13 añade:  AuthController

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // RecetasDatasource registrado como RecetasRepository
    // → Controllers solo conocen el contrato abstracto
    Get.lazyPut<RecetasRepository>(
      () => RecetasDatasource(),
      fenix: true,
    );

    // AuthController registrado globalmente
    Get.lazyPut<AuthController>(
      () => AuthController(),
      fenix: true,
    );

  }
}
