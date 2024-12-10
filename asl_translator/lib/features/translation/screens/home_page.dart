// lib/features/translation/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';
import '../../shared/widgets/settings_drawer.dart';
import 'dart:io';
import 'prediction.dart';
import 'package:camera/camera.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleImageSelection(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PredictionScreen(image: _selectedImage!)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handlePredict() async {
    if (_selectedImage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PredictionScreen(image: _selectedImage!),
        ),
      );
    }
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50.0),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      endDrawer: const SettingsDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Image Selection", style: Theme.of(context).textTheme.headlineMedium),
            Expanded(
              child: Center(
                child: Text(
                  'No image selected',
                  style: TextStyle(
                    fontSize: 16,
                    color: dark ? Colors.grey[200] : Colors.grey[700],
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _selectedImage != null ? _handlePredict : null,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                padding: WidgetStatePropertyAll(EdgeInsets.only(
                  left: 15.0,
                  top: 10.0,
                  right: 15.0,
                  bottom: 10.0,
                )),
              ),
              // ElevatedButton.styleFrom(
              //   padding: const EdgeInsets.symmetric(vertical: 16),
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              // ),
              child: Container(
                alignment: Alignment.center,
                width: 100.0,
                child: Text("Predict", style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _handleImageSelection(ImageSource.camera),
                ),
                _buildOptionButton(
                  icon: Icons.photo_library,
                  label: 'Photo Library',
                  onTap: () => _handleImageSelection(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
