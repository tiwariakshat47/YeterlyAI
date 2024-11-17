import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/data_collection/data_collection.dart';
import 'package:flutter_project_1/features/translation/prediction.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> takePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> chooseFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            image == null ? Text("No image selected") : Image.file(image!),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return PredictionScreen();
                    },
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                padding: WidgetStatePropertyAll(EdgeInsets.only(
                  left: 15.0,
                  top: 10.0,
                  right: 15.0,
                  bottom: 10.0,
                )),
              ),
              child: Container(
                alignment: Alignment.bottomCenter,
                width: 100.0,
                child: Text("prediction", style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: "UploadData",
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
            child: Icon(Icons.file_upload_outlined),
          ),
          FloatingActionButton(
            heroTag: "TakePhoto",
            onPressed: takePhoto,
            tooltip: "Take Photo",
            child: Icon(Icons.camera),
          ),
          FloatingActionButton(
            heroTag: "ChooseFromGallery",
            onPressed: chooseFromGallery,
            tooltip: "Choose from Gallery",
            child: Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}

