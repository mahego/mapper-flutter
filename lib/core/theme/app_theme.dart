import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de diseño extraídos de fletapp-angular (styles.scss, componentes).
class AppTheme {
  // === Glass (Angular :root) ===
  static const Color glassSurface = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static double get glassSurfaceOpacity => 0.08;
  static double get glassBorderOpacity => 0.16;
  static double get glassHighlightOpacity => 0.65;
  static const double glassBlur = 16.0;

  // === Acentos (Angular --accent, --accent-2) ===
  static const Color accentOrange = Color(0xFFf97316); // Orange 500
  static const Color accentCyan = Color(0xFF06b6d4);   // Cyan 500

  // Primary = acento naranja para CTAs
  static const Color primaryColor = accentOrange;
  static const Color primaryDark = Color(0xFFEA580C);  // Orange 600
  static const Color primaryLight = Color(0xFFfb923c);  // Orange 400
  static const Color primary400 = primaryLight;
  static const Color primary500 = primaryColor;
  static const Color primary600 = Color(0xFFEA580C);
  static const Color accent = accentOrange;
  static const Color accent2 = accentCyan;

  // Slate (Angular bg-slate-950, body)
  static const Color slate950 = Color(0xFF020617);     // #0b1020 → 0x0b1020
  static const Color ink = Color(0xFF0b1020);          // --ink
  static const Color slate900 = Color(0xFF0F172A);     // Card/Surface
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color white = Colors.white;

  // Semantic
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF22C55E);
  static const Color warningColor = Color(0xFFF59E0B);
  
  // Light Theme (Optional for now, focusing on Dark "Tropical" Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryLight,
        surface: Colors.white,
        error: errorColor,
        // Using Slate 50 as background for light mode
        background: const Color(0xFFF8FAFC), 
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: slate900,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: slate900,
        ),
      ),
      textTheme: _buildTextTheme(Colors.black87),
      elevatedButtonTheme: _elevatedButtonThemeData,
      inputDecorationTheme: _inputDecorationTheme(Colors.grey[100]!, slate200),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: slate200),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }

  // Dark Theme (Main "Tropical" Theme)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryLight,
        surface: slate900,
        background: slate950,
        error: errorColor,
      ),
      scaffoldBackgroundColor: slate950,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent, // Transparent for Glass effect
        foregroundColor: white,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      textTheme: _buildTextTheme(slate200),
      elevatedButtonTheme: _elevatedButtonThemeData,
      cardTheme: CardThemeData(
        elevation: 0,
        color: slate900.withOpacity(0.5), // Glassy look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: white.withOpacity(0.1)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      inputDecorationTheme: _inputDecorationTheme(slate900, slate700),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textColor.withOpacity(0.8),
      ),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonThemeData {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: white,
        backgroundColor: primaryColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return white.withOpacity(0.1);
          }
          return null;
        }),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color fillColor, Color borderColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: TextStyle(color: slate400),
      hintStyle: TextStyle(color: slate400),
    );
  }
}
