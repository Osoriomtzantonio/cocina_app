import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importamos la pantalla de inicio

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
      // Nombre de la app
      title: 'CocinaApp',
      // Oculta el banner de debug
      debugShowCheckedModeBanner: false,
      // Tema principal de la aplicación
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B35), // Naranja principal
        ),
        useMaterial3: true,
      ),
      // Pantalla inicial: HomeScreen
      home: const HomeScreen(),
    );
  }
}
