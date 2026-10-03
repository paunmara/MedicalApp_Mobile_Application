import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const primaryBlue = Color(0xFF64A4FF);
  static const primaryBlueDark = Color(0xFF3C8AF7);
  static const activeChoiceBlue = Color(0xFF0047AB);
  static const borderBlue = Color(0xFFA4CFFF);
  static const surfaceBlueLight = Color(0xFFF8FBFF);
  static const choiceUnselected = Color(0xFFBCDCFF);
  static const choiceUnselectedBorder = Color(0xFF7FB3FF);
  static const choiceUnselectedText = Color(0xFF1F3B5C);
  static const headerBlue = Color(0xFFA7C7E7);
  static const textDark = Color(0xFF2C3E50);
  static const errorRed = Color(0xFFD35454);
  static const errorBg = Color(0xFFFFE0E0);
  static const errorBorder = Color(0xFFFFBABA);
  static const goodGreen = Color(0xFF69D49A);
  static const goodGreenBg = Color(0xFFE6FFF1);
  static const warnOrange = Color(0xFFFFB36A);
  static const warnOrangeBg = Color(0xFFFFF3E6);
  static const gradientTop = Color(0xFFDCEEFF);
  static const gradientBottom = Color(0xFFCFE8FF);
}

const appBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.gradientTop, AppColors.gradientBottom],
);

TextStyle heroTextStyle({double fontSize = 34}) {
  return GoogleFonts.chewy(
    fontSize: fontSize,
    color: Colors.white,
    letterSpacing: 1,
    shadows: const [
      Shadow(offset: Offset(2, 2), color: Colors.black),
      Shadow(offset: Offset(4, 4), color: Colors.black),
    ],
  );
}

Widget appCard({
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.all(16),
}) {
  return Card(
    color: Colors.white,
    elevation: 3,
    shadowColor: Colors.black.withOpacity(0.08),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    child: Padding(padding: padding, child: child),
  );
}

ThemeData buildAppTheme() {
  final baseTextTheme = GoogleFonts.quicksandTextTheme(ThemeData.light().textTheme)
      .apply(bodyColor: AppColors.textDark, displayColor: AppColors.textDark);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.activeChoiceBlue,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.textDark,
      error: AppColors.errorRed,
      onError: Colors.white,
    ),

    textTheme: baseTextTheme,

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.headerBlue,
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
      titleTextStyle: baseTextTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceBlueLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.borderBlue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.borderBlue, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.primaryBlueDark, width: 2),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        side: const BorderSide(color: AppColors.borderBlue, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.choiceUnselected,
      selectedColor: AppColors.activeChoiceBlue,
      side: const BorderSide(color: AppColors.choiceUnselectedBorder, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}