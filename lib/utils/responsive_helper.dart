import 'package:flutter/material.dart';

// ── PUNTOS DE QUIEBRE (breakpoints) ──────────────────────────────────
// Definen en qué ancho cambia el diseño de la pantalla
class Breakpoints {
  Breakpoints._();
  static const double mobile  = 600;   // Menos de 600px = celular
  static const double tablet  = 900;   // 600-900px = tablet
  // Más de 900px = tablet grande / desktop
}

// ── CLASE HELPER RESPONSIVE ───────────────────────────────────────────
// Centraliza toda la lógica de tamaños y columnas
// Se usa pasándole el BuildContext para obtener el tamaño de la pantalla
class ResponsiveHelper {
  // Ancho y alto de la pantalla obtenidos con MediaQuery
  final double screenWidth;
  final double screenHeight;
  // Orientación del dispositivo
  final Orientation orientation;

  const ResponsiveHelper._({
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
  });

  // Constructor de fábrica: obtiene los datos del contexto automáticamente
  factory ResponsiveHelper.of(BuildContext context) {
    // MediaQuery.of(context) da acceso a todas las métricas del dispositivo
    final mediaQuery = MediaQuery.of(context);
    return ResponsiveHelper._(
      screenWidth:  mediaQuery.size.width,
      screenHeight: mediaQuery.size.height,
      orientation:  mediaQuery.orientation,
    );
  }

  // ── TIPO DE DISPOSITIVO ───────────────────────────────────────────
  bool get esCelular       => screenWidth <  Breakpoints.mobile;
  bool get esTablet        => screenWidth >= Breakpoints.mobile &&
                              screenWidth <  Breakpoints.tablet;
  bool get esTabletGrande  => screenWidth >= Breakpoints.tablet;
  bool get esHorizontal    => orientation == Orientation.landscape;

  // ── COLUMNAS DEL GRID DE RECETAS ─────────────────────────────────
  // Retorna cuántas columnas mostrar según el ancho de pantalla
  int get columnasGrid {
    if (esTabletGrande) return 4; // Tablet grande o desktop
    if (esTablet)       return 3; // Tablet
    if (esHorizontal)   return 3; // Celular en horizontal
    return 2;                     // Celular en vertical (default)
  }

  // ── COLUMNAS DEL GRID DE CATEGORÍAS ──────────────────────────────
  int get columnasCategorias {
    if (esTabletGrande) return 6;
    if (esTablet)       return 5;
    return 4;
  }

  // ── TAMAÑOS DE TEXTO ADAPTABLES ───────────────────────────────────
  // El texto es un poco más grande en tablets
  double get fontSizeTitulo  => esTabletGrande ? 28 : (esTablet ? 24 : 20);
  double get fontSizeCuerpo  => esTabletGrande ? 16 : 14;

  // ── PADDING ADAPTABLE ─────────────────────────────────────────────
  double get paddingHorizontal => esTabletGrande ? 32 : (esTablet ? 24 : 16);

  // ── ALTO DE IMAGEN EN TARJETAS ────────────────────────────────────
  double get alturaImagenCard => esTabletGrande ? 180 : (esTablet ? 160 : 140);

  // ── MÉTODO ÚTIL: valor según dispositivo ─────────────────────────
  // Retorna un valor diferente según el tipo de pantalla
  T valor<T>({required T celular, required T tablet, T? tabletGrande}) {
    if (esTabletGrande && tabletGrande != null) return tabletGrande;
    if (esTablet) return tablet;
    return celular;
  }
}
