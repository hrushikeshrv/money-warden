import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


@immutable
class MwColors extends ThemeExtension<MwColors> {
  final Color mutedText;
  final Color backgroundDark1;
  final Color backgroundDark2;
  final Color backgroundLight1;
  final Color backgroundLight2;
  final Color primaryLight1;
  final Color primaryLight2;
  final Color primaryLight3;
  final Color primaryDark1;
  final Color primaryDark2;
  final Color primaryDark3;

  const MwColors({
    required this.mutedText,
    required this.backgroundDark1,
    required this.backgroundDark2,
    required this.backgroundLight1,
    required this.backgroundLight2,
    required this.primaryDark1,
    required this.primaryDark2,
    required this.primaryDark3,
    required this.primaryLight1,
    required this.primaryLight2,
    required this.primaryLight3,
  });

  @override
  MwColors copyWith({
    Color? mutedText,
    Color? backgroundDark1,
    Color? backgroundDark2,
    Color? backgroundLight1,
    Color? backgroundLight2,
    Color? primaryLight1,
    Color? primaryLight2,
    Color? primaryLight3,
    Color? primaryDark1,
    Color? primaryDark2,
    Color? primaryDark3,
  }) {
    return MwColors(
      mutedText: mutedText ?? this.mutedText,
      backgroundDark1: backgroundDark1 ?? this.backgroundDark1,
      backgroundDark2: backgroundDark2 ?? this.backgroundDark2,
      backgroundLight1: backgroundLight1 ?? this.backgroundLight1,
      backgroundLight2: backgroundLight2 ?? this.backgroundLight2,
      primaryLight1: primaryLight1 ?? this.primaryLight1,
      primaryLight2: primaryLight2 ?? this.primaryLight2,
      primaryLight3: primaryLight3 ?? this.primaryLight3,
      primaryDark1: primaryDark1 ?? this.primaryDark1,
      primaryDark2: primaryDark2 ?? this.primaryDark2,
      primaryDark3: primaryDark3 ?? this.primaryDark3,
    );
  }

  @override
  MwColors lerp(ThemeExtension<MwColors>? other, double t) {
    if (other is! MwColors) return this;

    return MwColors(
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      backgroundDark1: Color.lerp(backgroundDark1, other.backgroundDark1, t)!,
      backgroundDark2: Color.lerp(backgroundDark2, other.backgroundDark2, t)!,
      backgroundLight1: Color.lerp(backgroundLight1, other.backgroundLight1, t)!,
      backgroundLight2: Color.lerp(backgroundLight2, other.backgroundLight2, t)!,
      primaryLight1: Color.lerp(primaryLight1, other.primaryLight1, t)!,
      primaryLight2: Color.lerp(primaryLight2, other.primaryLight2, t)!,
      primaryLight3: Color.lerp(primaryLight3, other.primaryLight3, t)!,
      primaryDark1: Color.lerp(primaryDark1, other.primaryDark1, t)!,
      primaryDark2: Color.lerp(primaryDark2, other.primaryDark2, t)!,
      primaryDark3: Color.lerp(primaryDark3, other.primaryDark3, t)!,
    );
  }
}


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
  ),
  extensions: [
    MwColors(
      mutedText: Colors.grey.shade600,
      backgroundDark2: Colors.grey.shade500,
      backgroundDark1: Colors.grey.shade300,
      backgroundLight1: Colors.white,
      backgroundLight2: Colors.white,
      primaryLight3: const Color(0xFFBCFFC9),
      primaryLight2: const Color(0xFF7DFA97),
      primaryLight1: const Color(0xFF49D767),
      primaryDark1: const Color(0xFF237C36),
      primaryDark2: const Color(0xFF1B5026),
      primaryDark3: const Color(0xFF102A15),
    )
  ]
);