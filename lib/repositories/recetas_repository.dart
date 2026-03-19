import '../models/recipe_model.dart';
import '../models/category_model.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 12 — RecetasRepository (contrato abstracto)
// ══════════════════════════════════════════════════════════════
//
// Una clase abstracta define QUÉ operaciones existen,
// pero NO dice CÓMO se implementan.
//
// Ventaja clave:
//   - El Controller solo conoce este contrato
//   - Si mañana cambias la API por una local, o por un mock para pruebas,
//     solo cambias la implementación (Datasource), nunca el Controller
//
// Analogía: un contrato de trabajo dice "entregar reportes los lunes",
// no cómo se hacen los reportes.

abstract class RecetasRepository {
  /// Devuelve una receta aleatoria
  Future<RecipeModel?> obtenerAleatoria();

  /// Devuelve todas las recetas con un límite opcional
  Future<List<RecipeModel>> obtenerTodas({int limite = 20});

  /// Busca recetas por nombre (búsqueda parcial)
  Future<List<RecipeModel>> buscar(String query);

  /// Devuelve recetas de una categoría específica
  Future<List<RecipeModel>> porCategoria(String categoria);

  /// Devuelve el detalle completo de una receta por ID
  Future<RecipeModel?> obtenerDetalle(String id);

  /// Devuelve todas las categorías disponibles
  Future<List<CategoryModel>> obtenerCategorias();
}
