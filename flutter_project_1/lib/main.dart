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
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: new LoginScreen(),
    );
  }
}

