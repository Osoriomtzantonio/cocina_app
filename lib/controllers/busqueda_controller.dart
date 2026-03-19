import 'dart:async';
import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../repositories/recetas_repository.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12 — BusquedaController actualizado con Repository
// ══════════════════════════════════════════════════════════════
//
// Cambio respecto a Clase 11:
//   Antes: final _api = ApiService();
//   Ahora: Get.find<RecetasRepository>()
//
// El controller sigue funcionando igual desde la perspectiva de la UI.
// Solo cambia cómo obtiene los datos internamente.

class BusquedaController extends GetxController {
  final _repo = Get.find<RecetasRepository>();

  // ── OBSERVABLES ───────────────────────────────────────────────────
  final query          = ''.obs;
  final cargando       = false.obs;
  final resultados     = <RecipeModel>[].obs;
  final sinResultados  = false.obs;

  // El Timer para debounce NO necesita ser observable
  // (no afecta la UI directamente)
  Timer? _debounce;

  // ── MANEJADOR DEL CAMPO DE TEXTO ──────────────────────────────────
  void onQueryChanged(String valor) {
    query.value         = valor;
    sinResultados.value = false;

    if (valor.trim().isEmpty) {
      _debounce?.cancel();
      resultados.clear();
      cargando.value = false;
      return;
    }

    // Cancelamos el timer anterior y creamos uno nuevo
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => buscar(valor));
  }

  // ── BÚSQUEDA EN LA API ────────────────────────────────────────────
  Future<void> buscar(String q) async {
    cargando.value = true;

    final r = await _repo.buscar(q);

    // assignAll notifica a todos los Obx() que usen resultados
    resultados.assignAll(r);
    sinResultados.value = r.isEmpty && q.trim().isNotEmpty;
    cargando.value      = false;
  }

  // ── onClose: equivalente a dispose() ─────────────────────────────
  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
