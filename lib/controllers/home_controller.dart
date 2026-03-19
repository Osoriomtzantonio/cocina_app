import 'package:get/get.dart';
import '../models/recipe_model.dart';
import '../models/category_model.dart';
import '../repositories/recetas_repository.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12 — HomeController actualizado con Repository
// ══════════════════════════════════════════════════════════════
//
// Cambio respecto a Clase 11:
//   Antes: final _api = ApiService();  ← dependencia concreta
//   Ahora: Get.find<RecetasRepository>() ← dependencia abstracta
//
// Beneficio: el controller no sabe si los datos vienen de la red,
// de una base de datos local o de un mock para pruebas.
// Esa decisión la toma AppBinding (registrado en main.dart).
//
// Flujo de dependencias:
//   main.dart → AppBinding → RecetasDatasource (implementa RecetasRepository)
//   HomeController → Get.find<RecetasRepository>() → usa lo que AppBinding registró

class HomeController extends GetxController {
  // Get.find busca la instancia ya registrada por AppBinding
  // Si no existe lanza un error (eso es útil: falla rápido y claro)
  final _repo = Get.find<RecetasRepository>();

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
      _repo.obtenerAleatoria(),
      _repo.obtenerCategorias(),
      _repo.obtenerTodas(limite: 6),    // recetas de nuestro backend
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
    final nueva = await _repo.obtenerAleatoria();
    if (nueva != null) recetaDia.value = nueva;
    cargandoReceta.value = false;
  }
}
