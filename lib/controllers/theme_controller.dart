import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════
// ThemeController — maneja el modo claro/oscuro de la app
//
// Persiste la preferencia en SharedPreferences para que
// la app recuerde el modo entre sesiones.
// ══════════════════════════════════════════════════════════════

class ThemeController extends GetxController {
  static const String _clave = 'modo_oscuro';

  final esModoOscuro = false.obs;

  @override
  void onInit() {
    super.onInit();
    _cargarPreferencia();
  }

  // ── CARGAR PREFERENCIA GUARDADA ───────────────────────────────────
  Future<void> _cargarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    final oscuro = prefs.getBool(_clave) ?? false;
    esModoOscuro.value = oscuro;
    Get.changeThemeMode(oscuro ? ThemeMode.dark : ThemeMode.light);
  }

  // ── ALTERNAR MODO ─────────────────────────────────────────────────
  Future<void> toggleTema() async {
    final nuevoModo = !esModoOscuro.value;
    esModoOscuro.value = nuevoModo;

    // Cambia el tema en toda la app sin recargar
    Get.changeThemeMode(nuevoModo ? ThemeMode.dark : ThemeMode.light);

    // Persiste la preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clave, nuevoModo);
  }
}
