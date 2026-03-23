import '../models/recipe_model.dart';
import '../models/category_model.dart';
import '../repositories/recetas_repository.dart';
import '../services/api_service.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12 — RecetasDatasource (implementación concreta)
// ══════════════════════════════════════════════════════════════
//
// Implementa RecetasRepository usando la API HTTP (ApiService).
//
// Si en el futuro quieres:
//   - Usar una base de datos local → creas RecetasLocalDatasource
//   - Hacer pruebas sin internet   → creas RecetasMockDatasource
//   - Cambiar de API               → solo modificas este archivo
//
// El Controller y el Repository NO cambian en ninguno de esos casos.

class RecetasDatasource implements RecetasRepository {
  // Usamos ApiService como la capa de transporte HTTP
  final _api = ApiService();

  @override
  Future<RecipeModel?> obtenerAleatoria() =>
      _api.obtenerRecetaAleatoria();

  @override
  Future<List<RecipeModel>> obtenerTodas({int limite = 20}) =>
      _api.obtenerRecetas(limite: limite);

  @override
  Future<List<RecipeModel>> buscar(String query) =>
      _api.buscarRecetas(query);

  @override
  Future<List<RecipeModel>> porCategoria(String categoria) =>
      _api.obtenerRecetasPorCategoria(categoria);

  @override
  Future<RecipeModel?> obtenerDetalle(String id) =>
      _api.obtenerDetalle(id);

  @override
  Future<List<CategoryModel>> obtenerCategorias() =>
      _api.obtenerCategorias();

  @override
  Future<RecipeModel?> crearReceta(Map<String, dynamic> datos, String token) =>
      _api.crearReceta(datos, token);

  @override
  Future<RecipeModel?> actualizarReceta(String id, Map<String, dynamic> datos, String token) =>
      _api.actualizarReceta(id, datos, token);

  @override
  Future<bool> eliminarReceta(String id, String token) =>
      _api.eliminarReceta(id, token);
}
