import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50.0),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'About Sign2Text',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Version ${snapshot.data!.version}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Sign2Text is a sign language translation application that uses machine learning to convert sign language gestures into text in real-time.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            _buildFeatureSection(context),
            const SizedBox(height: 32),
            _buildCreditsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(Icons.translate, 'Real-time Translation'),
          _buildFeatureItem(Icons.camera_alt, 'Camera Integration'),
          _buildFeatureItem(Icons.photo_library, 'Image Upload'),
          _buildFeatureItem(Icons.history, 'Translation History'),
          _buildFeatureItem(Icons.verified_user, 'User Accounts'),
        ],
      ),
    );
  }

  Widget _buildCreditsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Credits',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        const Text(
          'Sign2Text was developed by Yeterly Software.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        const Text(
          '© 2024 Yeterly Software. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 90.0),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Text(text, textAlign: TextAlign.start),
        ],
      ),
    );
  }
}