import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 11 — HomeController con GetX
// ══════════════════════════════════════════════════════════════
//
// GetxController separa la LÓGICA de la UI:
//   HomeController → todo el estado y las llamadas a la API
//   HomeScreen     → solo construye widgets, sin lógica
//
// Equivalencias con el patrón anterior:
//   initState()             → onInit()
//   dispose()               → onClose()
//   setState(() => x = y)  → x.value = y
//   if (_cargando) ...      → Obx(() => ctrl.cargando.value ? ... : ...)

class HomeController extends GetxController {
  final _api = ApiService();

  // ── OBSERVABLES ───────────────────────────────────────────────────
  // .obs convierte la variable en "reactiva":
  // cualquier Obx() que la use se reconstruye automáticamente al cambiar

  final cargando      = true.obs;          // RxBool
  final error         = Rxn<String>();     // Rxn = observable que puede ser null
  final recetaDia     = Rxn<RecipeModel>();
  final categorias    = <CategoryModel>[].obs;  // RxList
  final populares     = <RecipeModel>[].obs;
  final cargandoReceta = false.obs;

  // ── onInit: equivalente a initState() ────────────────────────────
  @override
  void onInit() {
    super.onInit();
    cargarDatos();
  }

  // ── CARGA INICIAL ─────────────────────────────────────────────────
  Future<void> cargarDatos() async {
    cargando.value = true;
    error.value    = null;

    final resultados = await Future.wait([
      _api.obtenerRecetaAleatoria(),
      _api.obtenerCategorias(),
      _api.obtenerRecetas(limite: 6),   // recetas de nuestro backend
    ]);

    final receta   = resultados[0] as RecipeModel?;
    final cats     = resultados[1] as List<CategoryModel>;
    final pops     = resultados[2] as List<RecipeModel>;

    if (receta == null && cats.isEmpty) {
      error.value    = 'Sin conexión a internet.\nVerifica tu red e intenta de nuevo.';
      cargando.value = false;
      return;
    }

    // Asignar valores a los observables — automáticamente notifica a Obx()
    recetaDia.value = receta;
    categorias.assignAll(cats);                           // assignAll reemplaza la lista
    populares.assignAll(pops.length > 6 ? pops.sublist(0, 6) : pops);
    cargando.value  = false;
  }

  // ── RECARGAR RECETA DEL DÍA ───────────────────────────────────────
  Future<void> recargarRecetaDia() async {
    cargandoReceta.value = true;
    final nueva = await _api.obtenerRecetaAleatoria();
    if (nueva != null) recetaDia.value = nueva;
    cargandoReceta.value = false;
  }
}
