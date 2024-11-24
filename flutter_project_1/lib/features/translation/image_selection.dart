import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/data_collection/data_collection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';

class ImageSelection extends StatefulWidget {
  const ImageSelection({super.key});

  @override
  State<ImageSelection> createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<ImageSelection> {
  File? image;
  final ImagePicker picker = ImagePicker();
  String? predictionResult;

  Future<void> takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      await sendImageToServer(image!);
    }
  }

  Future<void> chooseFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
      await sendImageToServer(image!);
    }
  }

  Future<void> sendImageToServer(File imageFile) async {
    const String url = "http://127.0.0.1:5000/"; // Flask server URL
    final request = http.MultipartRequest("POST", Uri.parse(url));

    // Attach the file
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // The name of the key in Flask's `request.files`
        imageFile.path,
      ),
    );

    try {
      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        // Read the response
        final responseBody = await response.stream.bytesToString();
        setState(() {
          predictionResult = responseBody;
        });
      } else {
        setState(() {
          predictionResult = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        predictionResult = "Failed to connect to the server: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Selection"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image == null
                ? const Text("No image selected")
                : Image.file(image!, height: 200),
            const SizedBox(height: 16.0),
            predictionResult == null
                ? const Text("No prediction yet")
                : Text("Prediction: $predictionResult"),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return DataCollectionScreen();
                  },
                ),
              );
            },
            tooltip: "Upload Photo for Data Collection",
            child: const Icon(Icons.file_upload_outlined),
          ),
          FloatingActionButton(
            onPressed: takePhoto,
            tooltip: "Take Photo",
            child: const Icon(Icons.camera),
          ),
          FloatingActionButton(
            onPressed: chooseFromGallery,
            tooltip: "Choose from Gallery",
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
