import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Pantalla de búsqueda de recetas
// Por ahora es visual; la búsqueda real se conecta en Clase 09
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Controlador del campo de texto para leer lo que escribe el usuario
  final TextEditingController _controller = TextEditingController();
  // Texto actual de búsqueda
  String _query = '';

  @override
  void dispose() {
    // Libera el controlador cuando la pantalla se destruye
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buscar recetas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── BARRA DE BÚSQUEDA ──────────────────────────────────
          _buildBarraBusqueda(),

          // ── CONTENIDO: resultados o estado vacío ───────────────
          Expanded(
            child: _query.isEmpty
                ? _buildEstadoVacio()
                : _buildEstadoBuscando(),
          ),
        ],
      ),
    );
  }

  // ── BARRA DE BÚSQUEDA ────────────────────────────────────────────
  Widget _buildBarraBusqueda() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          // onChanged se llama cada vez que el usuario escribe
          onChanged: (value) {
            setState(() => _query = value);
          },
          decoration: InputDecoration(
            hintText: 'Escribe el nombre de una receta...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            // Ícono de lupa al inicio
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            // Botón X para borrar el texto
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── ESTADO VACÍO (sin búsqueda) ──────────────────────────────────
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('¿Qué quieres cocinar hoy?', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Escribe el nombre de una receta\npara comenzar a buscar',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── ESTADO BUSCANDO ──────────────────────────────────────────────
  Widget _buildEstadoBuscando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Buscando "$_query"...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'La búsqueda real se conecta en Clase 09',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
