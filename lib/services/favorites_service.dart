import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

// Servicio para gestionar los favoritos guardados localmente
// Usa SharedPreferences para persistir datos entre sesiones
class FavoritesService {
  // Clave con la que guardamos la lista en SharedPreferences
  static const String _claveFavoritos = 'favoritos';

  // ── OBTENER INSTANCIA DE SHAREDPREFERENCES ─────────────────────
  // SharedPreferences.getInstance() es asíncrono porque accede al disco
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // ── LEER: obtener todas las recetas favoritas ──────────────────
  Future<List<RecipeModel>> obtenerFavoritos() async {
    final prefs = await _prefs;

    // Leemos la lista de strings JSON guardada bajo la clave
    // Si no existe aún, devuelve una lista vacía
    final List<String> jsonList =
        prefs.getStringList(_claveFavoritos) ?? [];

    // Convertimos cada string JSON a un objeto RecipeModel
    return jsonList.map((jsonString) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return RecipeModel.fromJson(json);
    }).toList();
  }

  // ── GUARDAR: agregar una receta a favoritos ────────────────────
  Future<bool> guardarFavorito(RecipeModel receta) async {
    final prefs = await _prefs;

    // Obtenemos la lista actual
    final List<String> jsonList =
        prefs.getStringList(_claveFavoritos) ?? [];

    // Verificamos que no esté duplicada (por ID)
    final yaExiste = jsonList.any((jsonString) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json['idMeal'] == receta.idMeal;
    });

    if (yaExiste) return false; // Ya estaba guardada, no duplicamos

    // Convertimos la receta a JSON y la agregamos a la lista
    jsonList.add(jsonEncode(receta.toJson()));

    // Guardamos la lista actualizada en SharedPreferences
    await prefs.setStringList(_claveFavoritos, jsonList);
    return true; // Guardado exitoso
  }

  // ── ELIMINAR: quitar una receta de favoritos ───────────────────
  Future<void> eliminarFavorito(String idMeal) async {
    final prefs = await _prefs;

    final List<String> jsonList =
        prefs.getStringList(_claveFavoritos) ?? [];

    // Filtramos la lista quitando la receta con el ID indicado
    jsonList.removeWhere((jsonString) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json['idMeal'] == idMeal;
    });

    // Guardamos la lista ya sin esa receta
    await prefs.setStringList(_claveFavoritos, jsonList);
  }

  // ── VERIFICAR: saber si una receta ya está en favoritos ────────
  Future<bool> esFavorita(String idMeal) async {
    final prefs = await _prefs;

    final List<String> jsonList =
        prefs.getStringList(_claveFavoritos) ?? [];

    // Buscamos si algún elemento tiene el mismo ID
    return jsonList.any((jsonString) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return json['idMeal'] == idMeal;
    });
  }

  // ── LIMPIAR: eliminar todos los favoritos ──────────────────────
  Future<void> limpiarFavoritos() async {
    final prefs = await _prefs;
    await prefs.remove(_claveFavoritos);
  }
}
