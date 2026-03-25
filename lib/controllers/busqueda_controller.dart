import 'dart:async';
import 'package:get/get.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';
import '../repositories/recetas_repository.dart';

// ══════════════════════════════════════════════════════════════
// BusquedaController — búsqueda con debounce y filtros
//
// Novedad respecto a Clase 12:
//   - Carga categorías al iniciar para mostrar chips de filtro
//   - categoriaSeleccionada: chip activo (null = todos)
//   - Al seleccionar un chip filtra por categoría
//   - Al escribir, busca por nombre dentro de la categoría activa
// ══════════════════════════════════════════════════════════════

class BusquedaController extends GetxController {
  final _repo = Get.find<RecetasRepository>();

  // ── OBSERVABLES ───────────────────────────────────────────────────
  final query                 = ''.obs;
  final cargando              = false.obs;
  final resultados            = <RecipeModel>[].obs;
  final sinResultados         = false.obs;
  final categorias            = <CategoryModel>[].obs;
  final categoriaSeleccionada = Rxn<String>();  // null = sin filtro

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    _cargarCategorias();
  }

  // ── CARGAR CATEGORÍAS PARA LOS CHIPS ─────────────────────────────
  Future<void> _cargarCategorias() async {
    final lista = await _repo.obtenerCategorias();
    categorias.assignAll(lista);
  }

  // ── SELECCIONAR/DESELECCIONAR CATEGORÍA (toggle) ─────────────────
  void seleccionarCategoria(String nombre) {
    if (categoriaSeleccionada.value == nombre) {
      // Tap en el chip ya activo → quita el filtro
      categoriaSeleccionada.value = null;
    } else {
      categoriaSeleccionada.value = nombre;
    }

    // Re-ejecutar búsqueda con el filtro actualizado
    if (query.value.trim().isNotEmpty) {
      buscar(query.value);
    } else if (categoriaSeleccionada.value != null) {
      _buscarPorCategoria(categoriaSeleccionada.value!);
    } else {
      resultados.clear();
      sinResultados.value = false;
    }
  }

  // ── MANEJADOR DEL CAMPO DE TEXTO ─────────────────────────────────
  void onQueryChanged(String valor) {
    query.value         = valor;
    sinResultados.value = false;

    if (valor.trim().isEmpty) {
      _debounce?.cancel();
      // Si hay categoría activa, mostrar sus recetas
      if (categoriaSeleccionada.value != null) {
        _buscarPorCategoria(categoriaSeleccionada.value!);
      } else {
        resultados.clear();
        cargando.value = false;
      }
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => buscar(valor));
  }

  // ── BÚSQUEDA POR TEXTO ────────────────────────────────────────────
  Future<void> buscar(String q) async {
    cargando.value = true;

    List<RecipeModel> r;

    if (categoriaSeleccionada.value != null) {
      // Filtro activo: obtener recetas de la categoría y filtrar por nombre
      final porCat = await _repo.porCategoria(categoriaSeleccionada.value!);
      r = porCat
          .where((receta) =>
              receta.strMeal.toLowerCase().contains(q.toLowerCase()))
          .toList();
    } else {
      // Sin filtro: búsqueda global por nombre
      r = await _repo.buscar(q);
    }

    resultados.assignAll(r);
    sinResultados.value = r.isEmpty && q.trim().isNotEmpty;
    cargando.value      = false;
  }

  // ── BÚSQUEDA SOLO POR CATEGORÍA ───────────────────────────────────
  Future<void> _buscarPorCategoria(String categoria) async {
    cargando.value = true;
    final r = await _repo.porCategoria(categoria);
    resultados.assignAll(r);
    sinResultados.value = r.isEmpty;
    cargando.value = false;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
