import 'package:get/get.dart';
import '../controllers/home_controller.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12 — HomeBinding
// ══════════════════════════════════════════════════════════════
//
// Registra el HomeController para la pantalla de inicio.
//
// Se llama ANTES de que HomeScreen se construya, así que cuando
// HomeScreen hace Get.find<HomeController>(), la instancia ya existe.
//
// Get.lazyPut vs Get.put:
//   lazyPut → crea la instancia solo cuando alguien la pide (más eficiente)
//   put     → crea la instancia de inmediato al llamar dependencies()
//
// Usamos lazyPut aquí porque HomeController se pedirá enseguida
// (en el mismo frame que se carga la pantalla).

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
      fenix: true,
    );
  }
}
