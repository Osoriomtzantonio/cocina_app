import 'package:flutter/material.dart';

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
      // Pantalla inicial (temporal mientras construimos la app)
      home: const Scaffold(
        backgroundColor: Color(0xFFFF6B35),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de la app
              Icon(Icons.restaurant_menu, size: 80, color: Colors.white),
              SizedBox(height: 16),
              // Nombre de la app
              Text(
                'CocinaApp',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              // Subtítulo
              Text(
                'Recetario Inteligente',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
