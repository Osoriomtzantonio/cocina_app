import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../services/api_service.dart';
import '../widgets/recipe_grid.dart';

// ══════════════════════════════════════════════════════════════
// CLASE 09 — SearchScreen con búsqueda real y debounce
// ══════════════════════════════════════════════════════════════
//
// Novedad: debounce
//   Sin debounce: se llama a la API en CADA tecla que presiona el usuario
//   Con debounce: esperamos 500ms de inactividad antes de llamar la API
//   Esto ahorra llamadas innecesarias a la red
//
// Flujo:
//   Usuario escribe → onChanged cancela el timer anterior →
//   crea un nuevo timer de 500ms → si no escribe más → llama _buscar()

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();

  // ── DEBOUNCE: evita llamar la API en cada tecla ───────────────────
  // Timer es un temporizador que podemos cancelar y reiniciar
  Timer? _debounce;

  // Estados de la pantalla
  String _query = '';
  bool _cargando = false;
  bool _sinResultados = false;
  List<RecipeModel> _resultados = [];

  @override
  void dispose() {
    _controller.dispose();
    // Cancelamos el timer si la pantalla se destruye
    _debounce?.cancel();
    super.dispose();
  }

  // ── MANEJADOR DEL CAMPO DE TEXTO CON DEBOUNCE ─────────────────────
  void _onSearchChanged(String query) {
    setState(() {
      _query = query;
      _sinResultados = false;
    });

    // Si el campo está vacío, limpiamos resultados inmediatamente
    if (query.trim().isEmpty) {
      _debounce?.cancel();
      setState(() {
        _resultados = [];
        _cargando = false;
      });
      return;
    }

    // Cancelamos el timer anterior (si el usuario sigue escribiendo)
    _debounce?.cancel();

    // Creamos un nuevo timer: si el usuario no escribe en 500ms, buscamos
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _buscar(query);
    });
  }

  // ── BÚSQUEDA REAL EN LA API ───────────────────────────────────────
  Future<void> _buscar(String query) async {
    setState(() => _cargando = true);

    // await espera la respuesta de search.php
    final resultados = await _api.buscarRecetas(query);

    // Verificamos que el widget siga activo
    if (!mounted) return;

    setState(() {
      _cargando = false;
      _resultados = resultados;
      // Marcamos si no hubo resultados para mostrar el estado correspondiente
      _sinResultados = resultados.isEmpty && query.trim().isNotEmpty;
    });
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
          _buildBarraBusqueda(),
          Expanded(child: _buildContenido()),
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
          onChanged: _onSearchChanged, // Llama a nuestro método con debounce
          decoration: InputDecoration(
            hintText: 'Escribe el nombre de una receta...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.textSecondary),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged('');
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

  // ── CONTENIDO DINÁMICO ────────────────────────────────────────────
  Widget _buildContenido() {
    // Campo vacío → invitamos a buscar
    if (_query.isEmpty) return _buildEstadoVacio();

    // Buscando → spinner mientras esperamos la API
    if (_cargando) return _buildEstadoCargando();

    // Sin resultados
    if (_sinResultados) return _buildSinResultados();

    // Resultados encontrados → grid responsive
    return _buildResultados();
  }

  // ── ESTADO: CAMPO VACÍO ───────────────────────────────────────────
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('¿Qué quieres cocinar hoy?', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Escribe el nombre de una receta\npara comenzar a buscar',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── ESTADO: CARGANDO ─────────────────────────────────────────────
  Widget _buildEstadoCargando() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Buscando "$_query"...',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── ESTADO: SIN RESULTADOS ────────────────────────────────────────
  Widget _buildSinResultados() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            'Sin resultados para "$_query"',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otro nombre\no revisa la ortografía',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── ESTADO: RESULTADOS ENCONTRADOS ───────────────────────────────
  Widget _buildResultados() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            '${_resultados.length} resultado${_resultados.length != 1 ? "s" : ""} para "$_query"',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
        // Grid reutilizable — ya sabe navegar a RecipeDetailScreen
        Expanded(child: RecipeGrid(recetas: _resultados)),
      ],
    );
  }
}
