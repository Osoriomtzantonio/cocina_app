import 'package:get/get.dart';
import '../controllers/busqueda_controller.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12 — BusquedaBinding
// ══════════════════════════════════════════════════════════════
//
// Registra el BusquedaController para la pantalla de búsqueda.
//
// Separar los bindings por pantalla tiene dos ventajas:
//   1. Claridad: sabes exactamente qué controlador necesita cada pantalla
//   2. Memoria: fenix: true recrea el controller si fue eliminado,
//      pero no lo carga hasta que alguien lo solicite

class BusquedaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusquedaController>(
      () => BusquedaController(),
      fenix: true,
    );
  }
}
