import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/authentication/screens/login/login.dart';
import 'package:flutter_project_1/utils/theme/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: LoginScreen(),
    );
  }
}

/// data collection functionality, user chooses list of alphabet
/// can choose specific letter and add image data
/// access camera info: resolution, etc. --> save to user info

