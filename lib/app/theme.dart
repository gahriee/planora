import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary       = Color(0xFF7C3AED);
  static const primaryDark   = Color(0xFF8B5CF6);
  static const secondary     = Color(0xFF06B6D4);
  static const secondaryDark = Color(0xFF22D3EE);

  // Backgrounds
  static const background      = Color(0xFFF5F3FF);
  static const backgroundDark  = Color(0xFF0F0D1A);
  static const surface         = Color(0xFFFFFFFF);
  static const surfaceDark     = Color(0xFF1E1B2E);

  // Text
  static const textPrimary     = Color(0xFF1E1B2E);
  static const textPrimaryDark = Color(0xFFEDE9FE);
  static const textSecondary   = Color(0xFF6B7280);

  // Borders
  static const outline         = Color(0xFFDDD6FE);
  static const outlineDark     = Color(0xFF2E2A45);

  // Task priority
  static const priorityLow    = Color(0xFF22C55E);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityHigh   = Color(0xFFEF4444);

  // Task status
  static const statusTodo       = Color(0xFF94A3B8);
  static const statusInProgress = Color(0xFF3B82F6);
  static const statusDone       = Color(0xFF22C55E);

  // Semantic
  static const error   = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
}

final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary:   AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    surface:   AppColors.surface,
    error:     AppColors.error,
    outline:   AppColors.outline,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surface,
    selectedItemColor:   AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide.none,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary:   AppColors.primaryDark,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryDark,
    surface:   AppColors.surfaceDark,
    error:     Color(0xFFF87171),
    outline:   AppColors.outlineDark,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimaryDark,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  cardTheme: CardThemeData(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceDark,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor:     AppColors.surfaceDark,
    selectedItemColor:   AppColors.primaryDark,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide.none,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
);
