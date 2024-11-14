import 'package:flutter/material.dart';
import 'package:flutter_project_1/utils/theme/elevated_button_theme.dart';
import 'package:flutter_project_1/utils/theme/text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    brightness: Brightness.light,
    primaryColor: Colors.indigo[600],
    scaffoldBackgroundColor: Colors.white,
    textTheme: AppTextTheme.lightTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.lightElevatedButtonTheme,
  );
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    brightness: Brightness.dark,
    primaryColor: Colors.indigo[600],
    scaffoldBackgroundColor: Colors.black,
    textTheme: AppTextTheme.darkTextTheme,
    elevatedButtonTheme: AppElevatedButtonTheme.darkElevatedButtonTheme,
  );
}