import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════
// ThemeController — maneja el modo claro/oscuro de la app
//
// Usa un ValueNotifier estático para que el cambio de tema
// funcione correctamente en Flutter Web (GetX no actualiza
// el themeMode de GetMaterialApp después del primer build).
// ══════════════════════════════════════════════════════════════

class ThemeController extends GetxController {
  static const String _clave = 'modo_oscuro';

  // ValueNotifier es Flutter nativo y sí reactiva a ValueListenableBuilder
  static final temaNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  // Observable para que los widgets (ej. SwitchListTile) lean el estado
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
    _aplicarTema(oscuro);
  }

  // ── ALTERNAR MODO ─────────────────────────────────────────────────
  Future<void> toggleTema() async {
    final nuevoModo = !esModoOscuro.value;
    _aplicarTema(nuevoModo);

    // Persiste la preferencia
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clave, nuevoModo);
  }

  // ── APLICAR TEMA (actualiza observable, notifier y GetX) ──────────
  void _aplicarTema(bool oscuro) {
    esModoOscuro.value = oscuro;
    final modo = oscuro ? ThemeMode.dark : ThemeMode.light;
    temaNotifier.value = modo;

    // GetMaterialApp maneja el tema internamente vía GetMaterialController.
    // Get.changeThemeMode() actualiza ese controlador interno.
    // El try-catch protege el caso donde se llama antes de que runApp() termine.
    try {
      Get.changeThemeMode(modo);
      Get.forceAppUpdate();
    } catch (_) {
      // Se ejecutará correctamente la próxima vez (ej. al hacer toggle manual)
    }
  }
}
