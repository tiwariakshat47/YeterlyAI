// lib/features/shared/widgets/settings_drawer.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:sign2text/features/about/screens/about.dart';
import 'package:sign2text/features/data/screens/data_collection.dart';
import 'package:sign2text/features/data/screens/data_usage_disclaimer.dart';
import 'package:sign2text/features/authentication/screens/login/login.dart';
import 'package:provider/provider.dart';
import 'package:sign2text/features/authentication/services/auth_service.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    bool deleteData = false;
    final passwordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to delete your account? This action cannot be undone.',
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: deleteData,
                onChanged: (value) => setState(() => deleteData = value ?? false),
                title: const Text('Delete my uploaded data'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _handleAccountDeletion(
                context,
                passwordController.text,
                deleteData,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAccountDeletion(
      BuildContext context,
      String password,
      bool deleteData,
      ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not found');
      }

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      if (deleteData) {
        // Delete user data from backend
        final token = await user.getIdToken();
        final response = await http.delete(
          Uri.parse('https://asl-backend-dsjk.onrender.com/api/data-collection/user-data'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to delete user data');
        }
      }

      // Delete user account
      await user.delete();

      if (context.mounted) {
        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Remove loading
        Navigator.of(context).pop(); // Remove delete dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Drawer(
      width: 250.0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 100.0,
            child: DrawerHeader(
              decoration: BoxDecoration(color: dark ? Colors.deepPurple[600] : Colors.deepPurple[100]),
              child: Text("Settings", style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          ListTile(
            leading: const Icon(Iconsax.document_upload),
            title: const Text('Upload for Data Collection'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DataCollectionScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.document_text_1),
            title: const Text('Data Usage Policy'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DataUsageDisclaimer(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.trash, color: Colors.red),
            title: const Text('Delete Account'),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.logout),
            title: const Text('Log out'),
            onTap: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
