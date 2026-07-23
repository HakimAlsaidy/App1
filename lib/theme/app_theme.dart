import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Deep Blue Gradient
  static const Color primaryColor = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1257);
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF4DD0E1);
  
  // Status Colors
  static const Color successColor = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warningColor = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color errorColor = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color infoColor = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF4F6F9);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Year Colors
  static const Color year1444Color = Color(0xFF7B1FA2);
  static const Color year1444Light = Color(0xFFF3E5F5);
  static const Color year1445Color = Color(0xFF00695C);
  static const Color year1445Light = Color(0xFFE0F2F1);
  static const Color year1446Color = Color(0xFFE65100);
  static const Color year1446Light = Color(0xFFFFF3E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceLight,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundLight,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: textSecondary,
          fontSize: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: textHint,
          fontSize: 14,
        ),
        prefixIconColor: primaryColor,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withAlpha(102),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        extendedTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: infoLight,
        selectedColor: primaryColor,
        labelStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary),
        displayMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary),
        displaySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary, fontSize: 28),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary, fontSize: 24),
        headlineSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, color: textPrimary, fontSize: 20),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimary, fontSize: 18),
        titleMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimary, fontSize: 16),
        titleSmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14),
        bodyLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w400, color: textSecondary, fontSize: 12),
        labelLarge: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600, fontSize: 14),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A237E),
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          color: textSecondary,
        ),
      ),
      
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }
}
