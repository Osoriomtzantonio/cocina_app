import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Pantalla de recetas favoritas guardadas localmente
// El almacenamiento real se implementa en Clase 08
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis favoritas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildEstadoVacio(),
    );
  }

  // Estado vacío: cuando aún no hay recetas guardadas
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono grande decorativo
          Icon(
            Icons.favorite_border,
            size: 90,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text('Sin favoritas aún', style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          Text(
            'Explora recetas y guarda las\nque más te gusten',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Botón decorativo (funcional en Clase 08)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Explorar recetas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
