import 'dart:async';
import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 11 — BusquedaController con GetX
// ══════════════════════════════════════════════════════════════
//
// Antes (SearchScreen era StatefulWidget):
//   Timer? _debounce;
//   String _query = '';
//   bool _cargando = false;
//   List<RecipeModel> _resultados = [];
//   void _onSearchChanged(String q) { setState(...) }
//
// Ahora (SearchScreen será StatelessWidget):
//   Todo el estado y la lógica vive aquí.
//   La pantalla solo usa Obx() para reaccionar a los cambios.

class BusquedaController extends GetxController {
  final _api = ApiService();

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

    final r = await _api.buscarRecetas(q);

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
