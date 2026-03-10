import 'package:flutter/material.dart';

// Widget reutilizable: tarjeta de receta
// Se usará en HomeScreen, CategoryScreen y SearchScreen
class RecipeCard extends StatelessWidget {
  // Datos que recibe la tarjeta desde quien la usa
  final String nombre;
  final String categoria;
  final String area;
  final String imagenUrl;
  final VoidCallback? onTap; // Acción al tocar la tarjeta

  const RecipeCard({
    super.key,
    required this.nombre,
    required this.categoria,
    required this.area,
    required this.imagenUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // GestureDetector detecta cuando el usuario toca la tarjeta
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // ClipRRect recorta todo el contenido al borderRadius del Container
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          // ── COLUMN: organiza imagen y datos verticalmente ─────
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PARTE SUPERIOR: imagen con overlay ───────────
              _buildImagenConOverlay(),

              // ── PARTE INFERIOR: nombre y metadata ────────────
              _buildInfoReceta(),
            ],
          ),
        ),
      ),
    );
  }

  // ── IMAGEN CON OVERLAY (usa Stack) ────────────────────────────────
  Widget _buildImagenConOverlay() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      // Stack superpone widgets: la imagen va debajo, el badge encima
      child: Stack(
        children: [
          // ── CAPA 1: Imagen de la receta ───────────────────────
          Positioned.fill(
            child: imagenUrl.isNotEmpty
                ? Image.network(
                    imagenUrl,
                    fit: BoxFit.cover, // Cubre todo el espacio disponible
                    // Mientras carga la imagen, muestra un placeholder
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholder();
                    },
                    // Si la imagen falla, muestra el placeholder
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),

          // ── CAPA 2: Badge de área (país de origen) ───────────
          // Positioned coloca el widget en una posición exacta dentro del Stack
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              // ── ROW: ícono + texto del país ──────────────────
              child: Row(
                mainAxisSize: MainAxisSize.min, // Row ocupa solo lo necesario
                children: [
                  const Icon(Icons.public, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    area,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── CAPA 3: Degradado inferior (mejora legibilidad) ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── INFORMACIÓN DE LA RECETA ──────────────────────────────────────
  Widget _buildInfoReceta() {
    return Padding(
      padding: const EdgeInsets.all(12),
      // ── COLUMN: nombre arriba, metadata abajo ────────────────
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre de la receta
          Text(
            nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis, // "..." si el texto es muy largo
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // ── ROW: ícono categoría + nombre categoría ───────────
          Row(
            children: [
              // Ícono de categoría
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDE0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 12,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 6),
              // Nombre de la categoría
              Expanded(
                child: Text(
                  categoria,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PLACEHOLDER: se muestra mientras carga o si falla la imagen ───
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFFFEDE0),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 48,
          color: Color(0xFFFF6B35),
        ),
      ),
    );
  }
}
