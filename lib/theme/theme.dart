import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme defaultColorScheme = const ColorScheme.light().copyWith(
  primary: const Color(0xFF2DBA4B),
  onPrimary: const Color(0xFFFFFFFF),
  secondary: const Color(0xFF2DBBA1),
  onSecondary: const Color(0xFFFFFFFF),
  surface: const Color(0xFFF8F8F8),
  surfaceDim: const Color(0xFFE1E1E1),
  onSurface: const Color(0xFF1D1B20),
);

ThemeData defaultTheme = ThemeData(
  colorScheme: defaultColorScheme,
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.outfit(),
    headlineMedium: GoogleFonts.outfit(),
    headlineSmall: GoogleFonts.outfit(),
    titleLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.bold
    ),
    titleMedium: GoogleFonts.outfit(),
    titleSmall: GoogleFonts.outfit(),
    bodyLarge: GoogleFonts.poppins(),
    bodyMedium: GoogleFonts.poppins(
        fontSize: 14
    ),
    bodySmall: GoogleFonts.poppins(),
    labelLarge: GoogleFonts.ibmPlexMono(
        fontWeight: FontWeight.bold
    ),
    labelMedium: GoogleFonts.poppins(),
    labelSmall: GoogleFonts.ibmPlexMono()
  )
);