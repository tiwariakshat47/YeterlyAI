import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/authentication/screens/login/signup.dart';
import 'package:flutter_project_1/features/translation/image_selection.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_project_1/utils/constants/image_strings.dart';
import 'package:flutter_project_1/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(
              top: 56.0,
              left: 24.0,
              bottom: 24.0,
              right: 24.0,
            ),
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

              /// Form
              Form(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      /// Email
                      TextFormField(
                        decoration: const InputDecoration(prefixIcon: Icon(Iconsax.direct_right), labelText: 'Email'),
                      ),
                      const SizedBox(height: 16.0),
                      /// Password
                      TextFormField(
                        decoration: const InputDecoration(prefixIcon: Icon(Iconsax.password_check), labelText: 'Password', suffixIcon: Icon(Iconsax.eye_slash)),
                      ),
                      const SizedBox(height: 8.0),
                      /// Remember Me & Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Remember Me
                          Row(
                            children: [
                              Checkbox(value: true, onChanged: (value){}),
                              const Text('Remember me'),
                            ],
                          ),
                          /// Forget Password
                          TextButton(onPressed: (){}, child: const Text('Forgot your password?')),
                        ],
                      ),
                      const SizedBox(height: 32.0),
                      /// Sign-In Button
                      SizedBox(width: double.infinity, child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ImageSelection();
                                },
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                          ),
                          child: Text('Sign In', style: Theme.of(context).textTheme.labelSmall)
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      /// Create Account Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return SignupScreen();
                                },
                              ),
                            );
                          },
                          child: Text('Create Account', style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),
              /// Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Divider(color: dark ? Colors.grey.shade800 : Colors.grey, thickness: 0.5, indent: 60, endIndent: 5)),
                  Text('Or Sign In With', style: Theme.of(context).textTheme.labelMedium),
                  Flexible(child: Divider(color: dark ? Colors.grey.shade800 : Colors.grey, thickness: 0.5, indent: 5, endIndent: 60)),
                ],
              ),
              const SizedBox(height: 32.0),
              /// Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(100)),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Image(
                        width: 24.0,
                        height: 24.0,
                        image: AssetImage(AppImages.google),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

