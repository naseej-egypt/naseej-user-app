import 'package:flutter/material.dart';

class AppColor {
  // Grayscale
  static const Color grey = Color(0xff8e8e8e);
  static const Color grey2 = Color.fromARGB(255, 66, 66, 66);
  static const Color black = Color(0xff000000);
  static const Color whiteColor = Colors.white;

  // Primary Background - Warm Beige/Cream (Egyptian Cotton)
  static const Color backgroundcolor = Color(0xfff1e9db);
  static const Color backgroundcolor2 = Color(0xffe8dcc8);

  // Primary Brand Colors - Deep Burgundy/Maroon (Traditional Carpet Colors)
  static const Color primaryColor = Color(0xff8b3c3c); // Deep burgundy
  static const Color secondColor = Color(0xffc26b6b); // Lighter burgundy
  static const Color thirdColor = Color(0xff541d2c); // Darker burgundy
  static const Color fourthColor = Color(0xffdf9696); // Soft pink-burgundy

  // Accent Colors - Gold/Bronze (Egyptian Heritage)
  static const Color goldAccent = Color(0xffd4a574); // Warm gold
  static const Color bronzeAccent = Color(0xffb8956a); // Bronze

  // Earthy Tones (Carpet Weaving Colors)
  static const Color earthBrown = Color(0xff8b7355);
  static const Color desertSand = Color(0xffd9c5a8);
  static const Color terracotta = Color(0xffc96a5c);

  // Status Colors
  static const Color warningColor = Colors.redAccent;
  static const Color successColor = Color(0xff6b8b3c);
  static const Color blackColor = Colors.black;

  // Card & Surface Colors
  static const Color cardBackground = Color(0xfffefdfb);
  static const Color cardShadow = Color(0x1a000000);

  // Neutral colors
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);
  static const Color borderGray = Color(0xFFE0E0E0);
}

// Extended App Colors for Carpet Store
class AppColors {
  // Primary colors matching your logo
  static const Color primaryBurgundy = Color(0xFF8b3c3c);
  static const Color secondaryBurgundy = Color(0xFFc26b6b);
  static const Color lightBurgundy = Color(0xFFdf9696);
  static const Color darkBurgundy = Color(0xFF541d2c);

  // Background colors
  static const Color creamBackground = Color(0xFFF1E9DB);
  static const Color lightCream = Color(0xFFFEFDFB);
  static const Color warmBeige = Color(0xFFE8DCC8);

  // Accent colors
  static const Color goldAccent = Color(0xFFD4A574);
  static const Color bronzeAccent = Color(0xFFB8956A);
  static const Color earthBrown = Color(0xFF8B7355);

  // Neutral colors
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color mediumText = Color(0xFF666666);
  static const Color lightText = Color(0xFF999999);
  static const Color borderGray = Color(0xFFE0E0E0);

  // Status colors
  static const Color success = Color(0xFF6B8B3C);
  static const Color error = Color(0xFFC96A5C);
  static const Color warning = Color(0xFFD4A574);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBurgundy, secondaryBurgundy],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [creamBackground, lightCream],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// Extension to easily access theme colors
extension AppColorsExtension on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}