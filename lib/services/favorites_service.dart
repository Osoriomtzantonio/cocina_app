import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';
import 'api_service.dart' show ApiService;
import 'auth_service.dart';

// ══════════════════════════════════════════════════════════════
// FavoritesService — favoritos en servidor (con login) o local
// ══════════════════════════════════════════════════════════════
//
// Estrategia dual:
//   - Usuario logueado   → favoritos en el servidor (FastAPI)
//   - Usuario sin login  → favoritos locales (SharedPreferences)
//
// Esto permite que la app funcione aunque no esté logueado.

class FavoritesService {
  final AuthService _auth = AuthService();
  static const String _claveLocal = 'favoritos';

  // ── HEADERS CON JWT ───────────────────────────────────────────────
  Future<Map<String, String>?> _headersAuth() async {
    final token = await _auth.obtenerToken();
    if (token == null) return null;
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ══════════════════════════════════════════════════════════════════
  // FAVORITOS EN SERVIDOR (usuario logueado)
  // ══════════════════════════════════════════════════════════════════

  Future<List<RecipeModel>> _obtenerFavoritosServidor(Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/favoritos'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data  = jsonDecode(response.body) as Map<String, dynamic>;
        final meals = data['meals'];
        if (meals == null) return [];
        return (meals as List)
            .map((j) => RecipeModel.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> _guardarFavoritoServidor(
      RecipeModel receta, Map<String, String> headers) async {
    try {
      final id = int.tryParse(receta.idMeal);
      if (id == null) return false;
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/favoritos/$id'),
        headers: headers,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<void> _eliminarFavoritoServidor(
      String idMeal, Map<String, String> headers) async {
    try {
      final id = int.tryParse(idMeal);
      if (id == null) return;
      await http.delete(
        Uri.parse('${ApiService.baseUrl}/favoritos/$id'),
        headers: headers,
      );
    } catch (e) {
      // silencioso
    }
  }

  Future<bool> _esFavoritaServidor(
      String idMeal, Map<String, String> headers) async {
    try {
      final id = int.tryParse(idMeal);
      if (id == null) return false;
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/favoritos/verificar/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['esFavorita'] as bool? ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // FAVORITOS LOCALES (SharedPreferences — sin login)
  // ══════════════════════════════════════════════════════════════════

  Future<List<RecipeModel>> _obtenerFavoritosLocal() async {
    final prefs   = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_claveLocal) ?? [];
    return jsonList.map((s) {
      return RecipeModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
    }).toList();
  }

  Future<bool> _guardarFavoritoLocal(RecipeModel receta) async {
    final prefs    = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_claveLocal) ?? [];
    final yaExiste = jsonList.any((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return j['idMeal'] == receta.idMeal;
    });
    if (yaExiste) return false;
    jsonList.add(jsonEncode(receta.toJson()));
    await prefs.setStringList(_claveLocal, jsonList);
    return true;
  }

  Future<void> _eliminarFavoritoLocal(String idMeal) async {
    final prefs    = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_claveLocal) ?? [];
    jsonList.removeWhere((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return j['idMeal'] == idMeal;
    });
    await prefs.setStringList(_claveLocal, jsonList);
  }

  Future<bool> _esFavoritaLocal(String idMeal) async {
    final prefs    = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_claveLocal) ?? [];
    return jsonList.any((s) {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return j['idMeal'] == idMeal;
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // API PÚBLICA — decide automáticamente servidor o local
  // ══════════════════════════════════════════════════════════════════

  Future<List<RecipeModel>> obtenerFavoritos() async {
    final headers = await _headersAuth();
    if (headers != null) return _obtenerFavoritosServidor(headers);
    return _obtenerFavoritosLocal();
  }

  Future<bool> guardarFavorito(RecipeModel receta) async {
    final headers = await _headersAuth();
    if (headers != null) return _guardarFavoritoServidor(receta, headers);
    return _guardarFavoritoLocal(receta);
  }

  Future<void> eliminarFavorito(String idMeal) async {
    final headers = await _headersAuth();
    if (headers != null) {
      await _eliminarFavoritoServidor(idMeal, headers);
    } else {
      await _eliminarFavoritoLocal(idMeal);
    }
  }

  Future<bool> esFavorita(String idMeal) async {
    final headers = await _headersAuth();
    if (headers != null) return _esFavoritaServidor(idMeal, headers);
    return _esFavoritaLocal(idMeal);
  }

  Future<void> limpiarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveLocal);
  }
}
