import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════
// ShoppingListService — lista de compras local (SharedPreferences)
//
// Cada ítem tiene: nombre, cantidad y si ya fue comprado.
// Los ingredientes se agregan desde RecipeDetailScreen.
// ══════════════════════════════════════════════════════════════

class ShoppingItem {
  final String nombre;
  final String cantidad;
  bool comprado;

  ShoppingItem({
    required this.nombre,
    required this.cantidad,
    this.comprado = false,
  });

  // Conversión a/desde JSON para guardar en SharedPreferences
  Map<String, dynamic> toJson() => {
    'nombre':   nombre,
    'cantidad': cantidad,
    'comprado': comprado,
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> j) => ShoppingItem(
    nombre:   j['nombre']   as String,
    cantidad: j['cantidad'] as String,
    comprado: j['comprado'] as bool? ?? false,
  );
}


class ShoppingListService {
  static const String _clave = 'lista_compras';

  // ── OBTENER LISTA ─────────────────────────────────────────────────
  Future<List<ShoppingItem>> obtenerLista() async {
    final prefs    = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_clave) ?? [];
    return jsonList
        .map((s) => ShoppingItem.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  // ── GUARDAR LISTA (escribe la lista completa) ─────────────────────
  Future<void> _guardarLista(List<ShoppingItem> lista) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _clave,
      lista.map((i) => jsonEncode(i.toJson())).toList(),
    );
  }

  // ── AGREGAR INGREDIENTES DE UNA RECETA ───────────────────────────
  // Recibe lista de maps {ingrediente, cantidad}, evita duplicados por nombre
  Future<int> agregarIngredientes(
      List<Map<String, String>> ingredientes) async {
    final lista = await obtenerLista();
    final nombresExistentes = lista.map((i) => i.nombre.toLowerCase()).toSet();

    int agregados = 0;
    for (final ing in ingredientes) {
      final nombre   = ing['ingrediente'] ?? '';
      final cantidad = ing['cantidad']    ?? '';
      if (nombre.isEmpty) continue;

      // Solo agregar si no existe ya en la lista
      if (!nombresExistentes.contains(nombre.toLowerCase())) {
        lista.add(ShoppingItem(nombre: nombre, cantidad: cantidad));
        nombresExistentes.add(nombre.toLowerCase());
        agregados++;
      }
    }

    await _guardarLista(lista);
    return agregados;
  }

  // ── MARCAR/DESMARCAR COMO COMPRADO ────────────────────────────────
  Future<void> toggleComprado(int index) async {
    final lista = await obtenerLista();
    if (index < 0 || index >= lista.length) return;
    lista[index].comprado = !lista[index].comprado;
    await _guardarLista(lista);
  }

  // ── ELIMINAR UN ÍTEM ──────────────────────────────────────────────
  Future<void> eliminarItem(int index) async {
    final lista = await obtenerLista();
    if (index < 0 || index >= lista.length) return;
    lista.removeAt(index);
    await _guardarLista(lista);
  }

  // ── LIMPIAR COMPRADOS ─────────────────────────────────────────────
  Future<void> limpiarComprados() async {
    final lista = await obtenerLista();
    lista.removeWhere((i) => i.comprado);
    await _guardarLista(lista);
  }

  // ── LIMPIAR TODA LA LISTA ─────────────────────────────────────────
  Future<void> limpiarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
  }

  // ── CONTAR ÍTEMS PENDIENTES ───────────────────────────────────────
  Future<int> contarPendientes() async {
    final lista = await obtenerLista();
    return lista.where((i) => !i.comprado).length;
  }
}
