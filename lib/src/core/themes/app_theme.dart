import 'package:flutter/material.dart';

class AppTheme {
  // Asosiy ranglar
  static const Color primaryColor = Color(0xFF8A9BB8);     // Nozik ko'k-ko'kimtir
  static const Color secondaryColor = Color(0xFFF2E9E4);   // Ochiq shaftoli
  static const Color accentColor = Color(0xFFD5BDAF);      // Och jigarrang
  static const Color textColor = Color(0xFF5C5C5C);        // To'q kulrang matn
  static const Color lightTextColor = Color(0xFF9A8C98);   // Och kulrang matn

  // Fon ranglari
  static const Color backgroundColor = Color(0xFFF8F9FA);  // Och fon
  static const Color cardColor = Color(0xFFFFFFFF);        // Oq kartalar
  static const Color hoverColor = Color(0xFFE9ECEF);       // Hover holati

  // Qarz turi indikatorlari
  static const Color debtColor = Colors.redAccent;        // Qarz ko'rsatkichi
  static const Color creditColor = Colors.greenAccent;      // Olgan qarz ko'rsatkichi

  // Maxsus holat ranglari
  static const Color warningColor = Color(0xFFF4ACB7);     // Ogohlantirish
  static const Color successColor = Color(0xFF9ED8DB);     // Muaffaqiyat
  static const Color errorColor = Color(0xFFE29578);       // Xato

  // ThemeData yaratish
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          color: lightTextColor,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryColor.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1),
        ),
        hintStyle: const TextStyle(color: lightTextColor),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shadowColor: primaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: lightTextColor.withValues(alpha: 0.2),
        thickness: 1,
      ),
    );
  }
}
