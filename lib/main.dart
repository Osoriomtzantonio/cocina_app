import 'package:flutter/material.dart';
import 'package:get/get.dart';          // Clase 11: GetX
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CocinaApp());
}

class CocinaApp extends StatelessWidget {
  const CocinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetMaterialApp es un reemplazo directo de MaterialApp
    // Habilita navegación, snackbars y diálogos de GetX sin necesidad de context
    return GetMaterialApp(
      title: 'CocinaApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}
