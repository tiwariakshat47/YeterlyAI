import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/data_collection/data_collection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageSelection extends StatefulWidget {
  const ImageSelection({super.key});

  @override
  State<ImageSelection> createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<ImageSelection> {
  Uint8List? imageBytes; // Use Uint8List for web compatibility
  final ImagePicker picker = ImagePicker();
  String? predictionResult;

  Future<void> takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Read file as bytes
      setState(() {
        imageBytes = bytes;
      });
      await sendImageToServer(bytes, pickedFile.name);
    }
  }

  Future<void> chooseFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes(); // Read file as bytes
      setState(() {
        imageBytes = bytes;
      });
      await sendImageToServer(bytes, pickedFile.name);
    }
  }

  Future<void> sendImageToServer(Uint8List imageBytes, String fileName) async {
  const String url = "http://127.0.0.1:5000/"; // Ensure the Flask server is running here
  print("Starting image upload...");

  try {
    final request = http.MultipartRequest("POST", Uri.parse(url));

    // Attach the file as bytes
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      imageBytes,
      filename: fileName,
    ));

    print("Sending request...");
    final response = await request.send();

    print("Response received with status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      print("Prediction result: $responseBody");
      setState(() {
        predictionResult = responseBody; // Update prediction result
      });
    } else {
      print("Error from server: ${response.statusCode}");
    }
  } catch (e) {
    print("Failed to connect to the server: $e");
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
            imageBytes == null
                ? const Text("No image selected")
                : Image.memory(imageBytes!, height: 200), // Display image from bytes
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
