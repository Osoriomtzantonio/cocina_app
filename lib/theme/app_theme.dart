import 'package:flutter/material.dart';

// ── COLORES DE LA APLICACIÓN ─────────────────────────────────────────
// Centralizamos todos los colores aquí para mantener consistencia visual
class AppColors {
  // Constructor privado: esta clase no debe instanciarse
  AppColors._();

  // ── Colores principales (Hex: 0xFF + código hex sin #) ───────────
  static const Color primary       = Color(0xFFFF6B35); // Naranja principal
  static const Color primaryDark   = Color(0xFFE8521A); // Naranja oscuro
  static const Color primaryLight  = Color(0xFFFFEDE0); // Naranja muy claro

  // ── Colores de fondo ─────────────────────────────────────────────
  static const Color background    = Color(0xFFF5F5F5); // Gris claro de fondo
  static const Color surface       = Colors.white;       // Superficies (tarjetas)

  // ── Colores de texto ─────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF222222); // Texto principal
  static const Color textSecondary = Color(0xFF888888); // Texto secundario
  static const Color textHint      = Color(0xFFBBBBBB); // Texto de placeholder

  // ── Colores semánticos (RGB: Color.fromRGBO(R, G, B, Opacidad)) ──
  // Color.fromRGBO recibe valores entre 0-255 para R, G, B y 0.0-1.0 para opacidad
  static final Color success = Color.fromRGBO(76, 175, 80, 1.0);   // Verde
  static final Color error   = Color.fromRGBO(244, 67, 54, 1.0);   // Rojo
  static final Color warning = Color.fromRGBO(255, 152, 0, 1.0);   // Amarillo

  // ── Material Colors (paleta predefinida de Flutter) ──────────────
  // MaterialColor tiene variantes del 50 al 900
  static const MaterialColor primarySwatch = Colors.deepOrange;
  static const Color grey50  = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
}

// ── ESTILOS DE TEXTO ─────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // ── Títulos ──────────────────────────────────────────────────────
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,  // ExtraBold
    color: AppColors.textPrimary,
    letterSpacing: -0.5,          // Letras ligeramente más juntas
    height: 1.2,                  // Interlineado (1.2 = 120% del fontSize)
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,  // Bold = w700
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,  // SemiBold
    color: AppColors.textPrimary,
  );

  // ── Cuerpo ───────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.6, // Más espacio entre líneas para mejor lectura
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ── Etiquetas y badges ───────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5, // Letras ligeramente separadas
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );

  // ── Botones ──────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.3,
  );
}

// ── TEMA GLOBAL DE LA APLICACIÓN ─────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── TEMA CLARO ────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge:  AppTextStyles.heading1,
      headlineMedium: AppTextStyles.heading2,
      headlineSmall:  AppTextStyles.heading3,
      bodyLarge:      AppTextStyles.bodyLarge,
      bodyMedium:     AppTextStyles.bodyMedium,
      bodySmall:      AppTextStyles.bodySmall,
      labelSmall:     AppTextStyles.caption,
    ),
  );

  // ── TEMA OSCURO ───────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: const Color(0xFF1E1E1E),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardColor: const Color(0xFF1E1E1E),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1A1A1A),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.white54,
    ),
    textTheme: TextTheme(
      headlineLarge:  AppTextStyles.heading1.copyWith(color: Colors.white),
      headlineMedium: AppTextStyles.heading2.copyWith(color: Colors.white),
      headlineSmall:  AppTextStyles.heading3.copyWith(color: Colors.white),
      bodyLarge:      AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
      bodyMedium:     AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
      bodySmall:      AppTextStyles.bodySmall.copyWith(color: Colors.white54),
      labelSmall:     AppTextStyles.caption.copyWith(color: Colors.white38),
    ),
  );
}
