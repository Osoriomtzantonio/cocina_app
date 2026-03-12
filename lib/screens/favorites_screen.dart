import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/recipe_model.dart';
import '../services/favorites_service.dart';

// Pantalla de recetas favoritas — lee del almacenamiento local (offline)
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();

  // Lista de recetas cargadas desde SharedPreferences
  List<RecipeModel> _favoritos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  // ── CARGAR favoritos desde SharedPreferences ───────────────────
  Future<void> _cargarFavoritos() async {
    setState(() => _cargando = true);
    // Lee los datos guardados localmente (no necesita internet)
    final lista = await _favoritesService.obtenerFavoritos();
    if (mounted) {
      setState(() {
        _favoritos = lista;
        _cargando  = false;
      });
    }
  }

  // ── ELIMINAR un favorito con opción de deshacer ────────────────
  Future<void> _eliminarFavorito(RecipeModel receta) async {
    await _favoritesService.eliminarFavorito(receta.idMeal);
    // Recargamos la lista actualizada
    await _cargarFavoritos();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${receta.strMeal} eliminada de favoritos'),
          backgroundColor: AppColors.textSecondary,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Deshacer',
            textColor: Colors.white,
            onPressed: () async {
              // Volvemos a guardar la receta eliminada
              await _favoritesService.guardarFavorito(receta);
              await _cargarFavoritos();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _favoritos.isEmpty
              ? 'Mis favoritas'
              : 'Mis favoritas (${_favoritos.length})',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Botón para recargar la lista
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarFavoritos,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? _buildCargando()
          : _favoritos.isEmpty
              ? _buildEstadoVacio()
              : _buildListaFavoritos(),
    );
  }

  // ── ESTADO: cargando ───────────────────────────────────────────
  Widget _buildCargando() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  // ── ESTADO: sin favoritos ──────────────────────────────────────
  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 90,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text('Sin favoritas aún', style: AppTextStyles.heading3),
          const SizedBox(height: 10),
          Text(
            'Explora recetas y toca el ♡\npara guardarlas aquí',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── LISTA DE FAVORITOS con opción de eliminar ──────────────────
  Widget _buildListaFavoritos() {
    return Column(
      children: [
        // Banner informativo: funciona sin internet
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.offline_pin, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                'Disponible sin conexión · ${_favoritos.length} receta${_favoritos.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),

        // Grid de recetas favoritas
        // Cada tarjeta tiene un botón largo de eliminar (Dismissible)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _favoritos.length,
            itemBuilder: (context, index) {
              final receta = _favoritos[index];
              // Dismissible permite deslizar la tarjeta para eliminarla
              return Dismissible(
                key: Key(receta.idMeal),
                direction: DismissDirection.endToStart, // Desliza de derecha a izquierda
                // Fondo rojo que aparece al deslizar
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white, size: 28),
                      SizedBox(height: 4),
                      Text('Eliminar',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
                onDismissed: (_) => _eliminarFavorito(receta),
                // Tarjeta de la receta
                child: _buildTarjetaFavorito(receta),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── TARJETA HORIZONTAL de favorito ────────────────────────────
  Widget _buildTarjetaFavorito(RecipeModel receta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Imagen de la receta ──────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft:    Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              receta.strMealThumb,
              width: 100, height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100, height: 100,
                color: AppColors.primaryLight,
                child: const Icon(Icons.restaurant,
                    color: AppColors.primary, size: 36),
              ),
            ),
          ),

          // ── Información de la receta ─────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.strMeal,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(receta.strCategory, style: AppTextStyles.bodySmall),
                      const SizedBox(width: 10),
                      const Icon(Icons.public,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(receta.strArea, style: AppTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Badge offline
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.offline_pin,
                                size: 11, color: AppColors.primary),
                            SizedBox(width: 3),
                            Text('Guardada',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Ícono de eliminar ────────────────────────────────
          IconButton(
            icon: const Icon(Icons.favorite,
                color: AppColors.primary, size: 22),
            onPressed: () => _eliminarFavorito(receta),
            tooltip: 'Quitar de favoritos',
          ),
        ],
      ),
    );
  }
}
