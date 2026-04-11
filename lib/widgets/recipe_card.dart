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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
              // ── PARTE SUPERIOR: imagen ocupa el espacio disponible ───
              // Expanded hace que la imagen tome todo el alto restante
              // después de que la sección de info fije su propio alto.
              // Así la imagen NUNCA desborda independientemente del tamaño.
              Expanded(child: _buildImagenConOverlay()),

              // ── PARTE INFERIOR: nombre y metadata ────────────
              _buildInfoReceta(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── IMAGEN CON OVERLAY (usa Stack) ────────────────────────────────
  // Sin altura fija: el Expanded del padre controla el tamaño.
  // StackFit.expand hace que el Stack rellene ese espacio por completo.
  Widget _buildImagenConOverlay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── CAPA 1: Imagen de la receta ───────────────────────
        _buildImagen(),

        // ── CAPA 2: Badge de área (país de origen) ───────────
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(20),
            ),
            // ── ROW: ícono + texto del país ──────────────────
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  Colors.black.withValues(alpha: 0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── INFORMACIÓN DE LA RECETA ──────────────────────────────────────
  Widget _buildInfoReceta(BuildContext context) {
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
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

  // ── IMAGEN: soporta assets locales y URLs de red ─────────────────
  Widget _buildImagen() {
    if (imagenUrl.isEmpty) return _buildPlaceholder();

    if (imagenUrl.startsWith('assets/')) {
      return Image.asset(
        imagenUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }

    return Image.network(
      imagenUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (_, _, _) => _buildPlaceholder(),
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
