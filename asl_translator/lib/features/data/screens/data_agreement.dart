import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/helpers/permission_handler.dart';
import '../../authentication/screens/auth_page.dart';

import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';

class DataAgreementScreen extends StatelessWidget {
  const DataAgreementScreen({Key? key}) : super(key: key);

  Future<void> _handleAgree(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreement_accepted', true);

    if (!context.mounted) return;

    // Request permissions
    final hasPermissions = await PermissionHandler.checkAndRequestPermissions();
    if (!hasPermissions) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions are required to use the app')),
      );
      return;
    }

    if (!context.mounted) return;

    // Navigate to login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50.0),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How We Use Your Data',
              style: Theme.of(context).textTheme.headlineMedium
            ),
            const SizedBox(height: 24),
            Text(
              'Yeterly AI Sign2Text stores your uploaded images to a secure database, only to be used by Yeterly Software for training and improving our Sign Language recognition models. We will keep your data private!',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Using Yeterly AI Sign2Text will require providing us access to your camera and photo library. By using this application, you are agreeing to provide us with access to uploaded images of your choice, your camera, and photo library.',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleAgree(context),
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                ),
                child: Text('Agree', style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
