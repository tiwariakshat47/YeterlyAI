import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/authentication/screens/data_usage_disclaimer.dart';
import 'package:flutter_project_1/utils/constants/image_strings.dart';
import 'package:flutter_project_1/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
      ),
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
                  Text('Welcome!', style: Theme.of(context).textTheme.headlineMedium),
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
                      const SizedBox(height: 16.0),
                      /// Re-Enter Password
                      TextFormField(
                        decoration: const InputDecoration(prefixIcon: Icon(Iconsax.password_check), labelText: 'Confirm password', suffixIcon: Icon(Iconsax.eye_slash)),
                      ),
                      const SizedBox(height: 32.0),
                      /// Sign-Up Button
                      SizedBox(width: double.infinity, child: ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return DataUsageDisclaimerScreen();
                                },
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                          ),
                          child: Text('Sign Up', style: Theme.of(context).textTheme.labelSmall)
                      ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
