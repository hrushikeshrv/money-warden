import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Poppins',
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.grey.shade50,
  )
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Poppins',
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.grey.shade800
  )
);