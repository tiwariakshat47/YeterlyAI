import 'package:flutter/material.dart';
import 'package:flutter_project_1/features/about.dart';
import 'package:flutter_project_1/features/authentication/screens/login/login.dart';
import 'package:flutter_project_1/utils/constants/image_strings.dart';
import 'package:flutter_project_1/utils/helpers/helper_functions.dart';
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
    var dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50.0),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
      ),
      endDrawer: SettingsDrawer(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            left: 24.0,
            bottom: 115.0,
            right: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20.0),
              Text("Image Selection", style: Theme.of(context).textTheme.headlineMedium),
              Expanded(
                child: image == null ? SizedBox(height: 200.0, child: Align(alignment: Alignment.center, child: Text("No image selected"))) : Image.file(image!),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    if (image != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PredictionScreen(image: image);
                          },
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            "Please select or take an image first")),
                      );
                    }
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
                    alignment: Alignment.center,
                    width: 100.0,
                    child: Text("Predict", style: Theme.of(context).textTheme.labelSmall),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "TakePhoto",
                onPressed: takePhoto,
                tooltip: "Take Photo",
                child: Icon(Icons.camera),
              ),
              SizedBox(height: 10.0),
              Text("Camera", style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: "ChooseFromGallery",
                onPressed: chooseFromGallery,
                tooltip: "Choose from Gallery",
                child: Icon(Icons.photo_library),
              ),
              SizedBox(height: 10.0),
              Text("Photo Library", style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250.0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 100.0,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple[100]),
              child: Text("Settings", style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          ListTile(
            title: Text("Upload for Data Collection", style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return DataCollectionScreen();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text("About Us", style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AboutScreen();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text("Log out", style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

