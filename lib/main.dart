import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/app_binding.dart';     // Clase 12: dependencias globales
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CocinaApp());
}

class CocinaApp extends StatelessWidget {
  const CocinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CocinaApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      // ── CLASE 12: initialBinding ────────────────────────────────────
      // initialBinding se ejecuta UNA VEZ antes de mostrar home.
      // AppBinding registra RecetasRepository (como RecetasDatasource)
      // para que esté disponible cuando HomeController y BusquedaController
      // hagan Get.find<RecetasRepository>().
      initialBinding: AppBinding(),

      home: const MainScreen(),
    );
  }
}
