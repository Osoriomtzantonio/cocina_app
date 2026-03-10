import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Pantalla de detalle de una receta
// Por ahora usa datos estáticos; en Clase 09 consumirá la API real
class RecipeDetailScreen extends StatefulWidget {
  // Datos básicos que recibe de la pantalla anterior
  final String idMeal;
  final String nombre;
  final String imagenUrl;

  const RecipeDetailScreen({
    super.key,
    required this.idMeal,
    required this.nombre,
    required this.imagenUrl,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // Estado del botón de favorito
  bool _esFavorita = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Usamos CustomScrollView para el efecto de imagen que se encoge al hacer scroll
      body: CustomScrollView(
        slivers: [
          // ── SLIVER APP BAR: imagen grande que se colapsa ─────────
          _buildSliverAppBar(),

          // ── CONTENIDO DE LA RECETA ────────────────────────────────
          SliverToBoxAdapter(
            child: _buildContenido(),
          ),
        ],
      ),
    );
  }

  // ── SLIVER APP BAR CON IMAGEN ────────────────────────────────────
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,        // Altura cuando está expandida
      pinned: true,               // Se queda visible al hacer scroll
      backgroundColor: AppColors.primary,
      // Ícono de regreso personalizado
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          // ── ÍCONO: flecha atrás ───────────────────────────────
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
      ),
      // Botón de favorito en la barra superior
      actions: [
        IconButton(
          onPressed: () {
            // Cambia el estado del favorito
            setState(() => _esFavorita = !_esFavorita);
            // Muestra confirmación con SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _esFavorita
                      ? 'Receta guardada en favoritos ✓'
                      : 'Receta eliminada de favoritos',
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: _esFavorita
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            // ── ÍCONO: corazón (cambia según estado) ─────────────
            child: Icon(
              _esFavorita ? Icons.favorite : Icons.favorite_border,
              // Cambia el color según si es favorita
              color: _esFavorita ? Colors.red[300] : Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      // Imagen grande de la receta
      flexibleSpace: FlexibleSpaceBar(
        // ── IMAGE.NETWORK: carga imagen desde URL ─────────────────
        background: _buildImagenPrincipal(),
      ),
    );
  }

  // ── IMAGEN PRINCIPAL DESDE URL ───────────────────────────────────
  Widget _buildImagenPrincipal() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image.network descarga y muestra una imagen desde internet
        Image.network(
          widget.imagenUrl,
          fit: BoxFit.cover, // La imagen cubre todo el espacio
          // loadingBuilder: se ejecuta mientras la imagen está descargando
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child; // Ya cargó
            return Container(
              color: AppColors.primaryLight,
              child: Center(
                child: CircularProgressIndicator(
                  // Muestra el progreso real de descarga
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          // errorBuilder: se ejecuta si la imagen no pudo cargarse
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryLight,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── ÍCONO: imagen rota ──────────────────────────
                  Icon(Icons.broken_image, size: 64, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text('No se pudo cargar la imagen',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            );
          },
        ),
        // Degradado oscuro en la parte inferior de la imagen
        Positioned(
          bottom: 0, left: 0, right: 0,
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── CONTENIDO PRINCIPAL DE LA RECETA ────────────────────────────
  Widget _buildContenido() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── NOMBRE DE LA RECETA ───────────────────────────────
          Text(
            widget.nombre,
            // Usamos el estilo heading1 del tema centralizado
            style: AppTextStyles.heading2,
          ),

          const SizedBox(height: 12),

          // ── BADGES DE METADATA (categoría, área, tiempo) ─────
          _buildMetadataBadges(),

          const SizedBox(height: 24),

          // ── DIVIDER: línea separadora ─────────────────────────
          const Divider(color: AppColors.grey200, height: 1),

          const SizedBox(height: 20),

          // ── SECCIÓN: INGREDIENTES ─────────────────────────────
          _buildSeccionIngredientes(),

          const SizedBox(height: 24),

          const Divider(color: AppColors.grey200, height: 1),

          const SizedBox(height: 20),

          // ── SECCIÓN: INSTRUCCIONES ────────────────────────────
          _buildSeccionInstrucciones(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── BADGES DE METADATA ───────────────────────────────────────────
  Widget _buildMetadataBadges() {
    return Wrap(
      spacing: 10,  // Espacio horizontal entre badges
      runSpacing: 8, // Espacio vertical si pasan a otra línea
      children: [
        _buildBadge(icon: Icons.restaurant_menu, texto: 'Chicken'),
        _buildBadge(icon: Icons.public,          texto: 'Japanese'),
        _buildBadge(icon: Icons.timer,           texto: '45 min'),
      ],
    );
  }

  // ── BADGE INDIVIDUAL ─────────────────────────────────────────────
  Widget _buildBadge({required IconData icon, required String texto}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── ÍCONO del badge ───────────────────────────────────
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          // ── TEXTO del badge con estilo label ─────────────────
          Text(
            texto,
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN: INGREDIENTES ────────────────────────────────────────
  Widget _buildSeccionIngredientes() {
    // Ingredientes de ejemplo (datos reales vendrán de la API en Clase 09)
    final ingredientes = [
      {'ingrediente': 'Soy Sauce',       'cantidad': '3/4 cup'},
      {'ingrediente': 'Water',           'cantidad': '1/2 cup'},
      {'ingrediente': 'Brown Sugar',     'cantidad': '1/4 cup'},
      {'ingrediente': 'Ground Ginger',   'cantidad': '1/2 tsp'},
      {'ingrediente': 'Minced Garlic',   'cantidad': '3 cloves'},
      {'ingrediente': 'Chicken Breast',  'cantidad': '4 pieces'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Título de sección con ícono ───────────────────────
        Row(
          children: [
            const Icon(Icons.kitchen, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('Ingredientes', style: AppTextStyles.heading3),
          ],
        ),
        const SizedBox(height: 14),

        // Lista de ingredientes
        ...ingredientes.map((item) => _buildIngredienteItem(
              ingrediente: item['ingrediente']!,
              cantidad: item['cantidad']!,
            )),
      ],
    );
  }

  // ── FILA DE UN INGREDIENTE ───────────────────────────────────────
  Widget _buildIngredienteItem({
    required String ingrediente,
    required String cantidad,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Punto decorativo naranja
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // ── Nombre del ingrediente (texto principal) ──────────
          Expanded(
            child: Text(ingrediente, style: AppTextStyles.bodyMedium),
          ),
          // ── Cantidad (texto secundario con color diferente) ───
          Text(
            cantidad,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN: INSTRUCCIONES ───────────────────────────────────────
  Widget _buildSeccionInstrucciones() {
    // Instrucciones de ejemplo divididas en pasos
    final pasos = [
      'Precalienta el horno a 175°C (350°F).',
      'Mezcla la salsa de soya, agua, azúcar morena, jengibre y ajo en un tazón.',
      'Coloca el pollo en un molde para hornear y vierte la salsa encima.',
      'Hornea por 35-45 minutos hasta que el pollo esté bien cocido.',
      'Sirve sobre arroz blanco y disfruta.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Título de sección con ícono ───────────────────────
        Row(
          children: [
            const Icon(Icons.format_list_numbered,
                color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('Instrucciones', style: AppTextStyles.heading3),
          ],
        ),
        const SizedBox(height: 14),

        // Lista de pasos numerados
        ...pasos.asMap().entries.map((entry) {
          final numero = entry.key + 1;
          final paso   = entry.value;
          return _buildPasoItem(numero: numero, descripcion: paso);
        }),
      ],
    );
  }

  // ── FILA DE UN PASO DE INSTRUCCIÓN ──────────────────────────────
  Widget _buildPasoItem({required int numero, required String descripcion}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Número del paso (círculo naranja) ─────────────────
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$numero',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Descripción del paso ──────────────────────────────
          Expanded(
            child: Text(
              descripcion,
              // bodyLarge tiene height: 1.6 para mejor legibilidad
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
