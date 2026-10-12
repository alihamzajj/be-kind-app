import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true);
  final body = GoogleFonts.figtreeTextTheme().apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  TextStyle display(double size) => GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        letterSpacing: -0.02 * size,
      );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.ground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    textTheme: TextTheme(
      displayLarge: display(38).copyWith(height: 1.05),
      headlineMedium: display(28),
      headlineSmall: display(25).copyWith(height: 1.2),
      titleMedium: body.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
      bodyLarge: body.bodyLarge?.copyWith(fontSize: 16, height: 1.5, color: AppColors.inkSoft),
      bodyMedium: body.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
      labelLarge: body.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
      labelSmall: body.labelSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(48, 52),
        side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.figtree(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.lineStrong, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.lineStrong, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accentSoft,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.figtree(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? AppColors.accent : AppColors.muted,
          )),
    ),
    dividerColor: AppColors.line,
  );
}
