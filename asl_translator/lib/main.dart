// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/auth_page.dart';
import 'widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase based on platform
  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASL Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Platform.isAndroid || Platform.isIOS
          ? AuthWrapper(cameras: cameras)
          : HomePage(cameras: cameras), // Skip auth on desktop for now
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final List<CameraDescription> cameras;

  const AuthWrapper({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        if (snapshot.hasData) {
          return HomePage(cameras: cameras);
        }
        return const AuthPage();
      },
    );
  }
}