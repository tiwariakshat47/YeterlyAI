import 'package:flutter/material.dart';
import 'package:sign2text/utils/theme/elevated_button_theme.dart';
import 'package:sign2text/utils/theme/text_theme.dart';

class AppTheme {
  AppTheme._();
  // Colors
  static const Color primary = Color(0xFF6750A4);
  static const Color secondary = Color(0xFFEADDFF);
  static const Color background = Colors.white;
  static const Color error = Color(0xFFB3261E);

  // Dark Colors
  static const Color darkPrimary = Color(0xFFD0BCFF);
  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkSurface = Color(0xFF2B2930);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    brightness: Brightness.light,
    primaryColor: Colors.deepPurple[600],
    scaffoldBackgroundColor: Colors.white,
    textTheme: AppTextTheme.lightTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurple[600],
    scaffoldBackgroundColor: Colors.grey[900],
    textTheme: AppTextTheme.darkTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
  );
}