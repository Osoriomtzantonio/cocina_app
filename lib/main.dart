import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/app_binding.dart';
import 'controllers/theme_controller.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ThemeController registrado permanentemente antes de runApp
  Get.put(ThemeController(), permanent: true);

  // Inicializar notificaciones locales (solo en mobile, se ignora en web)
  NotificationService().inicializar();

  runApp(const CocinaApp());
}

class CocinaApp extends StatelessWidget {
  const CocinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder escucha el ValueNotifier estático de ThemeController.
    // A diferencia de Obx + GetMaterialApp, esto SÍ funciona en Flutter Web
    // porque reconstruye el widget completo cada vez que cambia el notifier.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.temaNotifier,
      builder: (context, themeMode, _) => GetMaterialApp(
        title: 'CocinaApp',
        debugShowCheckedModeBanner: false,
        theme:     AppTheme.theme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        initialBinding: AppBinding(),
        home: const MainScreen(),
      ),
    );
  }
}
