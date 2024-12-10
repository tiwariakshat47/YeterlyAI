// lib/features/data/screens/data_collection.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({Key? key}) : super(key: key);

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  String _selectedLetter = 'A';
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  Map<String, String> _uploadedImages = {};

  @override
  void initState() {
    super.initState();
    _loadExistingImages();
  }

  Future<void> _loadExistingImages() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('https://asl-backend-dsjk.onrender.com/api/data-collection/images'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _uploadedImages = Map<String, String>.from(
              data.map((key, value) => MapEntry(key, value['image'] as String))
          );
        });
      }
    } catch (e) {
      AppHelperFunctions.showSnackBar(context, 'Failed to load images: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (bytes.length > 1000000) {
        if (mounted) {
          AppHelperFunctions.showSnackBar(
              context,
              'Image too large. Please select an image under 1000KB.'
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      final base64Image = base64Encode(bytes);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('https://asl-backend-dsjk.onrender.com/api/data-collection/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'letter': _selectedLetter,
          'image': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _uploadedImages[_selectedLetter] = base64Image;
        });
        if (mounted) {
          AppHelperFunctions.showSnackBar(context, 'Image uploaded successfully');
        }
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      if (mounted) {
        AppHelperFunctions.showSnackBar(context, 'Upload failed: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteImage(String letter) async {
    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();

      final response = await http.delete(
        Uri.parse('https://asl-backend-dsjk.onrender.com/api/data-collection/images/$letter'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _uploadedImages.remove(letter);
        });
        if (mounted) {
          AppHelperFunctions.showSnackBar(context, 'Image deleted successfully');
        }
      } else {
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      if (mounted) {
        AppHelperFunctions.showSnackBar(context, 'Delete failed: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50.0),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload Image for Data Collection',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Select Letter',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              alignment: Alignment.center,
              width: 200,
              child: DropdownButton<String>(
                value: _selectedLetter,
                isExpanded: true,
                items: List.generate(26, (index) {
                  final letter = String.fromCharCode(65 + index);
                  return DropdownMenuItem(
                    value: letter,
                    child: Center(
                      child: Text(
                        letter,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  );
                }),
                menuMaxHeight: 300,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedLetter = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploadImage,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                padding: WidgetStatePropertyAll(EdgeInsets.only(
                  left: 15.0,
                  top: 10.0,
                  right: 15.0,
                  bottom: 10.0,
                )),
              ),
              child: Text('Upload Image', style: Theme.of(context).textTheme.labelSmall),
            ),
            const SizedBox(height: 32),
            if (_uploadedImages.isNotEmpty) ...[
              const Text(
                'Uploaded Images',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _uploadedImages.length,
                itemBuilder: (context, index) {
                  final letter = _uploadedImages.keys.elementAt(index);
                  final imageData = _uploadedImages[letter]!;
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Image.memory(
                                base64Decode(imageData),
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              'Letter $letter',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Iconsax.trash, color: Colors.red),
                          onPressed: () => _deleteImage(letter),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
