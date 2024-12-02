import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/home_page.dart';
import 'screens/auth_page.dart';
import 'widgets/loading_screen.dart';
import 'services/auth_service.dart';
import 'services/asl_interpreter_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<ASLInterpreterService>(
          create: (_) => ASLInterpreterService(),
        ),
      ],
      child: MaterialApp(
        title: 'ASL Translator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const InitializationWrapper(),
      ),
    );
  }
}

class InitializationWrapper extends StatefulWidget {
  const InitializationWrapper({Key? key}) : super(key: key);

  @override
  State<InitializationWrapper> createState() => _InitializationWrapperState();
}

class _InitializationWrapperState extends State<InitializationWrapper> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    final interpreter = Provider.of<ASLInterpreterService>(context, listen: false);
    final cameras = await availableCameras();
    await interpreter.initialize();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Platform.isAndroid || Platform.isIOS
            ? _AuthWrapper(cameras: cameras)
            : HomePage(cameras: cameras),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        return const LoadingScreen();
      },
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  final List<CameraDescription> cameras;

  const _AuthWrapper({Key? key, required this.cameras}) : super(key: key);

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
