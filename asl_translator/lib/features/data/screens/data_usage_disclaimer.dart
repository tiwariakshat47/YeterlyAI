import 'package:flutter/material.dart';
import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';

class DataUsageDisclaimer extends StatelessWidget {
  const DataUsageDisclaimer({Key? key}) : super(key: key);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How We Use Your Data', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16.0),
            Text(
              'Data Collection and Usage',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign2Text collects and processes sign language images to provide translation services. Here\'s what you need to know:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildSection(
              'Data Collection',
              'We collect images of sign language gestures only when you explicitly choose to capture or upload them.',
            ),
            _buildSection(
              'Data Usage',
              'Your images are used solely for providing real-time translation services and improving our translation accuracy.',
            ),
            _buildSection(
              'Data Storage',
              'Images are processed in real-time and are not permanently stored unless you explicitly choose to save them.',
            ),
            _buildSection(
              'Data Protection',
              'We employ industry-standard security measures to protect your data during transmission and processing.',
            ),
            _buildSection(
              'User Rights',
              'You have the right to access, modify, or delete any saved data associated with your account.',
            ),
            const SizedBox(height: 24),
            const Text(
              'By using Sign2Text, you agree to these data collection and usage terms.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all<EdgeInsets>(
                      EdgeInsets.all(15)),
                  backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                ),
                child: Text('I Understand', style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black,
            ),
          ),
          const SizedBox(height: 3),
          Text(content),
        ],
      ),
    );
  }
}
