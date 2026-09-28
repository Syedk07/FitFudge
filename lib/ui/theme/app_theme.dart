import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// FitFudge brand palette — warm leather & parchment athletic identity.
///
/// Scheme roles on dark backgrounds:
///   Interactive accent  →  secondary  =  #CFB595  (warm parchment gold)
///   Dark surface / icon →  primary    =  #351E10  (deep espresso brown)
class AppColors {
  AppColors._();

  // ── Core brand ──────────────────────────────────────────────────────────────
  /// Deep espresso brown — button backgrounds, dark icon fill, logo background.
  static const Color primary = Color(0xFF351E10);
  static const Color primaryLight = Color(0xFF4E2D17);
  static const Color primaryDark = Color(0xFF1F110A);

  /// Warm parchment gold — the visible accent / interactive colour.
  static const Color secondary = Color(0xFFCFB595);
  static const Color secondaryLight = Color(0xFFE8D5B7);
  static const Color secondaryDark = Color(0xFFAA9070);

  // ── Backgrounds ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF110C08);
  static const Color surface = Color(0xFF1A1008);
  static const Color surfaceElevated = Color(0xFF251709);
  static const Color cardBackground = Color(0xFF211409);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5ECD7);
  static const Color textSecondary = Color(0xFFCFB595);
  static const Color textMuted = Color(0xFF7A6248);

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF5DBB7A);
  static const Color warning = Color(0xFFD4A017);
  static const Color error = Color(0xFFCC4B3A);
  static const Color info = Color(0xFF4A90C4);

  // ── Dividers & borders ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFF2E1F10);
  static const Color border = Color(0xFF3A2415);

  // ── Muscle-group accent colours ─────────────────────────────────────────────
  static const Color chestColor = Color(0xFFCC4B3A);
  static const Color backColor = Color(0xFF4A90C4);
  static const Color legsColor = Color(0xFF5DBB7A);
  static const Color shoulderColor = Color(0xFFD4A017);
  static const Color bicepColor = Color(0xFF9B6BB5);
  static const Color tricepColor = Color(0xFFCF5E7A);
  static const Color coreColor = Color(0xFF2EBFB8);
  static const Color gluteColor = Color(0xFFE07840);
  static const Color cardioColor = Color(0xFFCFB595);
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,

      // In Material 3, `primary` drives most interactive widget colours.
      // We map our visible accent (gold) to `primary` in the ColorScheme so
      // that Buttons, FABs, checkboxes etc. use gold automatically.
      colorScheme: const ColorScheme.dark(
        primary: AppColors.secondary,       // gold — visible accent
        onPrimary: AppColors.primary,       // deep brown text on gold surfaces
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.textPrimary,
      ),

      // ─── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // Android
          statusBarBrightness: Brightness.dark,       // iOS
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // ─── Bottom Navigation ───────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.secondary,   // gold selected tab
        unselectedItemColor: AppColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ─── Cards ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      // ─── Elevated Button — gold bg / dark text ───────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ─── Outlined Button — gold border / gold text ───────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Text Button ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Input / TextField ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),

      // ─── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.secondary.withValues(alpha: 0.25),
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13),
        side: const BorderSide(color: AppColors.border),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ─── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ─── FloatingActionButton — gold bg / dark icon ───────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ─── Slider ──────────────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.secondary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.secondary,
        overlayColor: AppColors.secondary.withValues(alpha: 0.2),
      ),

      // ─── Switch ──────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.secondary
                : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.secondary.withValues(alpha: 0.4)
                : AppColors.border),
      ),

      // ─── Checkbox ────────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.secondary
                : Colors.transparent),
        checkColor: WidgetStateProperty.all(AppColors.primary),
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)),
      ),

      // ─── ListTile ────────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ─── Progress Indicator ──────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondary,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),

      // ─── Tab Bar ─────────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.secondary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ─── Text Styles ─────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800),
        displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700),
        displaySmall: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600),
        titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        titleSmall: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        bodyMedium:
            TextStyle(color: AppColors.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 12),
        labelLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600),
        labelMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500),
        labelSmall: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Returns the accent colour for a given muscle-group label.
Color muscleGroupColor(String muscle) {
  final m = muscle.toLowerCase();
  if (m.contains('chest')) return AppColors.chestColor;
  if (m.contains('back') || m.contains('lat') || m.contains('trap')) {
    return AppColors.backColor;
  }
  if (m.contains('leg') ||
      m.contains('quad') ||
      m.contains('hamstring') ||
      m.contains('calf') ||
      m.contains('calves')) {
    return AppColors.legsColor;
  }
  if (m.contains('shoulder') || m.contains('delt')) {
    return AppColors.shoulderColor;
  }
  if (m.contains('bicep')) { return AppColors.bicepColor; }
  if (m.contains('tricep')) { return AppColors.tricepColor; }
  if (m.contains('core') || m.contains('ab')) { return AppColors.coreColor; }
  if (m.contains('glute')) { return AppColors.gluteColor; }
  if (m.contains('cardio') ||
      m.contains('conditioning') ||
      m.contains('power')) {
    return AppColors.cardioColor;
  }
  return AppColors.textSecondary;
}

/// Returns the colour matching a difficulty level.
Color difficultyColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'beginner':
      return AppColors.success;
    case 'intermediate':
      return AppColors.warning;
    case 'advanced':
      return AppColors.error;
    default:
      return AppColors.textMuted;
  }
}
