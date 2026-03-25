import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/app_binding.dart';
import 'controllers/theme_controller.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ThemeController se inicializa ANTES de runApp para que
  // cargue la preferencia guardada y el tema sea correcto desde el inicio
  Get.put(ThemeController(), permanent: true);

  runApp(const CocinaApp());
}

class CocinaApp extends StatelessWidget {
  const CocinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    // Obx hace que GetMaterialApp se reconstruya cuando esModoOscuro cambia,
    // pasando el themeMode correcto directamente — funciona en Web y Mobile
    return Obx(() => GetMaterialApp(
      title: 'CocinaApp',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeCtrl.esModoOscuro.value
          ? ThemeMode.dark
          : ThemeMode.light,
      initialBinding: AppBinding(),
      home: const MainScreen(),
    ));
  }
}
