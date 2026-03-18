import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../models/category_model.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 09 — Consumo de API propia con FastAPI
// ══════════════════════════════════════════════════════════════
//
// ApiService centraliza TODAS las llamadas al backend FastAPI.
// El formato JSON es idéntico al de TheMealDB, por lo que
// RecipeModel y CategoryModel no necesitan cambios.
//
// Endpoints:
//   /recetas/aleatoria        → receta aleatoria
//   /categorias               → lista de categorías
//   /recetas/categoria/{cat}  → recetas por categoría (simplificado)
//   /recetas/buscar?s=query   → buscar por nombre (completo)
//   /recetas/{id}             → detalle por ID
//   /auth/registro            → registrar usuario
//   /auth/login               → iniciar sesión
//   /favoritos                → favoritos del usuario autenticado

class ApiService {
  // ── URL BASE (se adapta según la plataforma) ──────────────────────
  //   Web/Desktop → localhost  (Flutter corre en el mismo equipo)
  //   Emulador Android → 10.0.2.2  (alias de localhost dentro del emulador)
  //   Celular físico → cambia por la IP local de tu PC (ej: 192.168.1.x)
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  static String get _baseUrl => baseUrl;

  // ── RECETA ALEATORIA ──────────────────────────────────────────────
  // Devuelve una RecipeModel con todos sus datos, o null si hubo error
  Future<RecipeModel?> obtenerRecetaAleatoria() async {
    try {
      // await pausa SOLO esta función hasta recibir la respuesta HTTP
      final response = await http.get(Uri.parse('$_baseUrl/recetas/aleatoria'));

      if (response.statusCode == 200) {
        // jsonDecode convierte el String JSON en un Map de Dart
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final meals = data['meals'] as List<dynamic>;
        // fromJson convierte el primer objeto del JSON en RecipeModel
        return RecipeModel.fromJson(meals.first as Map<String, dynamic>);
      }
      return null; // código HTTP distinto de 200
    } catch (e) {
      // Error de red, timeout, JSON malformado, etc.
      return null;
    }
  }

  // ── CATEGORÍAS ────────────────────────────────────────────────────
  Future<List<CategoryModel>> obtenerCategorias() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categorias'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final categories = data['categories'] as List<dynamic>;
        // .map() convierte cada elemento de la lista en un CategoryModel
        return categories
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── RECETAS POR CATEGORÍA ─────────────────────────────────────────
  // ¡IMPORTANTE! Este endpoint devuelve datos SIMPLIFICADOS:
  // solo idMeal, strMeal y strMealThumb.
  // NO incluye categoría, área, ingredientes ni instrucciones.
  // Para el detalle completo se usa obtenerDetalle().
  Future<List<RecipeModel>> obtenerRecetasPorCategoria(String categoria) async {
    try {
      final url = '$_baseUrl/recetas/categoria/${Uri.encodeComponent(categoria)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // La API devuelve null cuando no hay resultados para esa categoría
        if (data['meals'] == null) return [];
        final meals = data['meals'] as List<dynamic>;
        return meals
            .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── BUSCAR RECETAS ────────────────────────────────────────────────
  // Busca por nombre. Devuelve datos COMPLETOS (con categoría, área, etc.)
  Future<List<RecipeModel>> buscarRecetas(String query) async {
    // No llamamos a la API si el campo está vacío
    if (query.trim().isEmpty) return [];

    try {
      final url = '$_baseUrl/recetas/buscar?s=${Uri.encodeComponent(query)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['meals'] == null) return []; // Sin resultados
        final meals = data['meals'] as List<dynamic>;
        return meals
            .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── TODAS LAS RECETAS (para "populares" en HomeScreen) ───────────
  Future<List<RecipeModel>> obtenerRecetas({int limite = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/recetas?limite=$limite'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['meals'] == null) return [];
        final meals = data['meals'] as List<dynamic>;
        return meals
            .map((json) => RecipeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ── DETALLE COMPLETO DE UNA RECETA ───────────────────────────────
  // Obtiene todos los campos: ingredientes, instrucciones, etc.
  // Se usa desde RecipeDetailScreen y como complemento de filtros.
  Future<RecipeModel?> obtenerDetalle(String idMeal) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/recetas/$idMeal'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['meals'] == null) return null;
        final meals = data['meals'] as List<dynamic>;
        return RecipeModel.fromJson(meals.first as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
