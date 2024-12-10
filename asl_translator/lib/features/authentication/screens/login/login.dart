import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign2text/features/translation/screens/home_page.dart';
import 'package:sign2text/features/authentication/services/auth_service.dart';
import 'package:sign2text/features/authentication/screens/signup/signup.dart';
import 'package:sign2text/features/authentication/screens/reset_password/reset_password.dart';
import 'package:sign2text/utils/helpers/secure_storage.dart';
import 'package:sign2text/features/data/screens/data_usage_disclaimer.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';
import 'package:sign2text/utils/constants/image_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: Image.asset(AppImages.lightAppLogo, height: 40),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            /// Logo, Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                  height: 150, image: AssetImage(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo),
                ),
                Text('Welcome back!', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            SizedBox(height: 16.0),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Iconsax.direct_right),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Email is required';
                      if (!value!.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Iconsax.password_check),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Password is required';
                      if (value!.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      ),
                      Text('Remember me', style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                        ),
                        child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0),  // Add spacing

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    ElevatedButton(
                      onPressed: _handleLogin,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                      ),
                      child: Text('Log in', style: Theme.of(context).textTheme.labelSmall),
                    ),
                    const SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: Text('Don\'t have an account? Sign up', style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                  Row(  // Add new Row here
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DataUsageDisclaimer(),
                          ),
                        ),
                        child: Text('Data Usage Policy', style: TextStyle(decoration: TextDecoration.underline, fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.deepPurple[700])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await SecureStorage.getCredentials();
    if (credentials['remember_me'] == 'true') {
      setState(() {
        _emailController.text = credentials['email'] ?? '';
        _passwordController.text = credentials['password'] ?? '';
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _rememberMe,
      );

      if (!mounted) return;

      final cameras = await availableCameras();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage(cameras: cameras)),
            (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
/*
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  } */
}
