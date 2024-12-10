import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';
import '../../about/screens/about.dart';
import '../../data/screens/data_collection.dart';
import '../../authentication/screens/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../shared/widgets/settings_drawer.dart';
import 'prediction.dart';

class ImageSelection extends StatefulWidget {
  const ImageSelection({Key? key}) : super(key: key);

  @override
  State<ImageSelection> createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<ImageSelection> {
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
            MaterialPageRoute(
              builder: (_) => PredictionScreen(image: _selectedImage!),
            ),
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

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
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
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!)
                  : const Text('No image selected'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _handleImageSelection(ImageSource.camera),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(15)),
                    backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                  ),
                  child: Text('Take Photo', style: Theme.of(context).textTheme.labelSmall),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _handleImageSelection(ImageSource.gallery),
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(15)),
                    backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                  ),
                  child: Text('Upload Photo', style: Theme.of(context).textTheme.labelSmall),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
