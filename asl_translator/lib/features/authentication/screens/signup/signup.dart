// lib/features/authentication/screens/signup/signup.dart

import 'package:flutter/material.dart';
import 'package:sign2text/features/authentication/services/auth_service.dart';
import 'package:sign2text/features/authentication/screens/verification/email_verification.dart';
import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the terms and conditions')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        // title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
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
                Text('Welcome!', style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            SizedBox(height: 32.0),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
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
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Iconsax.password_check),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Password is required';
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Iconsax.password_check),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                    title: Text('I agree to the Terms & Conditions', style: Theme.of(context).textTheme.bodySmall),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    // style: ElevatedButton.styleFrom(
                    //   padding: const EdgeInsets.symmetric(vertical: 16),
                    // ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text('Sign Up', style: Theme.of(context).textTheme.labelSmall),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Already have an account? Sign in', style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
