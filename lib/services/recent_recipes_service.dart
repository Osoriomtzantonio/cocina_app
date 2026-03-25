import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

// ══════════════════════════════════════════════════════════════
// RecentRecipesService — guarda las últimas recetas vistas
//
// Almacena hasta 10 recetas en SharedPreferences.
// Se llama desde RecipeDetailScreen al abrir una receta.
// ══════════════════════════════════════════════════════════════

class RecentRecipesService {
  static const String _clave   = 'recetas_recientes';
  static const int    _maxItems = 10;

  // ── GUARDAR RECETA VISTA ──────────────────────────────────────────
  // La mueve al inicio si ya existe (más reciente primero)
  Future<void> guardarReceta(RecipeModel receta) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clave) ?? [];

    // Eliminar si ya existía (para no duplicar)
    lista.removeWhere((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return j['idMeal'] == receta.idMeal;
    });

    // Insertar al inicio (más reciente primero)
    lista.insert(0, jsonEncode(receta.toJson()));

    // Mantener solo los últimos _maxItems
    final recortada = lista.length > _maxItems
        ? lista.sublist(0, _maxItems)
        : lista;

    await prefs.setStringList(_clave, recortada);
  }

  // ── OBTENER LISTA ─────────────────────────────────────────────────
  Future<List<RecipeModel>> obtenerRecientes() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList(_clave) ?? [];
    return lista
        .map((s) =>
            RecipeModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  // ── LIMPIAR HISTORIAL ─────────────────────────────────────────────
  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
  }
}
