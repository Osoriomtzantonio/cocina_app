import 'package:flutter/material.dart';
import 'screens/main_screen.dart';   // Pantalla contenedora principal
import 'theme/app_theme.dart';       // Tema centralizado de la app

// Punto de entrada de la aplicación
void main() {
  runApp(const CocinaApp());
}

// Widget raíz de la aplicación
class CocinaApp extends StatelessWidget {
  const CocinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CocinaApp',
      debugShowCheckedModeBanner: false,
      // Usamos el tema centralizado definido en app_theme.dart
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}
