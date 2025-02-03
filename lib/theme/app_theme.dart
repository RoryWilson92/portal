import 'dart:math';
import 'package:flutter/material.dart';

class AppTheme {

  static const double zeroGR = 0.61803398875;
  static const double oneGR = 1 + zeroGR;

  static const Color textOnPrimary = Color.fromRGBO(255, 255, 255, 1);
  static const Color textOnAccent = Color.fromRGBO(0, 0, 0, 1);
  static const Color accent = Color.fromRGBO(255, 255, 0, 1);
  static final Color primary = darker(textOnPrimary, degree: 5);
  static final Color primaryContrast = lighter(primary);
  
  static final appThemeData = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: primaryContrast,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontFamily: "Product Sans",
        color: accent,
        fontSize: 36,
      ),
      iconTheme: const IconThemeData(color: accent),
    ),
    iconTheme: const IconThemeData(color: accent),
    fontFamily: "Product Sans",
    scaffoldBackgroundColor: primary,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: textOnPrimary,
        fontSize: 18,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: accent,
      selectionHandleColor: accent,
      selectionColor: opacity(accent, 0.4),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: primary,
      titleTextStyle: const TextStyle(
        fontFamily: "Product Sans",
        color: textOnPrimary,
        fontSize: 28,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(10),
      hintStyle: TextStyle(color: darker(textOnPrimary)),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: accent),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        textStyle: const TextStyle(
          fontFamily: "Product Sans",
          fontSize: 28,
        ),
        foregroundColor: textOnAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      iconSize: 32,
      foregroundColor: textOnAccent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primary,
      unselectedItemColor: textOnPrimary,
      selectedItemColor: accent,
    ),
    dividerTheme: DividerThemeData(
      color: darker(textOnPrimary, degree: 3),
      indent: 10,
      endIndent: 10,
      thickness: 0.5,
      space: 20,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accent,
    )
  );

  static Color darker(Color color, {int degree = 1}) {
    return color
        .withRed((color.red * pow(zeroGR, degree)).toInt())
        .withGreen((color.green * pow(zeroGR, degree)).toInt())
        .withBlue((color.blue * pow(zeroGR, degree)).toInt());
  }

  static Color lighter(Color color, {int degree = 1}) {
    return color
        .withRed((color.red * pow(oneGR, degree)).toInt())
        .withGreen((color.green * pow(oneGR, degree)).toInt())
        .withBlue((color.blue * pow(oneGR, degree)).toInt());
  }

  static Color opacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}