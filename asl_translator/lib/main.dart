import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/authentication/screens/auth_page.dart';
import 'features/shared/widgets/loading_screen.dart';
import 'features/authentication/services/auth_service.dart';
import 'features/translation/services/asl_interpreter_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io' show Platform;
import 'features/translation/screens/home_page.dart';
import 'utils/theme/theme.dart';
import 'utils/helpers/permission_handler.dart';
import 'features/data/screens/data_agreement.dart';

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
        debugShowCheckedModeBanner: false,
        title: 'Sign2Text',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const InitializationWrapper(),
          '/login': (context) => const AuthPage(),
          '/agreement': (context) => const DataAgreementScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            return MaterialPageRoute(
              builder: (_) => FutureBuilder<List<CameraDescription>>(
                future: availableCameras(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return HomePage(cameras: snapshot.data!);
                  }
                  return const LoadingScreen();
                },
              ),
            );
          }
          return null;
        },
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
    try {
      final interpreter = Provider.of<ASLInterpreterService>(context, listen: false);
      final auth = Provider.of<AuthService>(context, listen: false);
      await interpreter.initialize();

      if (!mounted) return;

      final hasCredentials = await auth.hasStoredCredentials();
      if (hasCredentials) {
        try {
          await auth.tryAutoLogin();
        } catch (e) {
          await auth.signOut();
        }
      }

      if (!mounted) return;

      final cameras = await availableCameras();
      final isFirstTime = await PermissionHandler.isFirstTimeUser();

      if (isFirstTime) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DataAgreementScreen()),
        );
        return;
      }

      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(cameras: cameras)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Initialization error: $e')),
        );
      }
    }
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

  const _AuthWrapper({
    Key? key,
    required this.cameras
  }) : super(key: key);

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
