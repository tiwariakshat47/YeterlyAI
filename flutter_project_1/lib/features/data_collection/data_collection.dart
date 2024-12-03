import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_project_1/utils/constants/image_strings.dart';
import 'package:flutter_project_1/utils/helpers/helper_functions.dart';
import 'package:flutter_project_1/features/translation/image_selection.dart';

const List<String> alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

class DataCollectionScreen extends StatefulWidget {
  const DataCollectionScreen({super.key});

  @override
  State<DataCollectionScreen> createState() => _DataCollectionScreenState();
}

class _DataCollectionScreenState extends State<DataCollectionScreen> {
  File? image;
  final ImagePicker picker = ImagePicker();

  bool _isImagePickerActive = false;
  bool _isImageUploaded = false; // Tracks if the image has been uploaded

  Future<void> chooseFromGallery() async {
    if (_isImagePickerActive) {
      print("Image picker is already active. Ignoring this request.");
      return;
    }
    _isImagePickerActive = true;
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
          _isImageUploaded = true; // Set to true when an image is uploaded
          print("Image selected");
        });
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error while picking image: $e");
    } finally {
      _isImagePickerActive = false; // Reset the flag
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Upload Image for Data Collection", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20.0),
              /// Letter Selection
              Text("Select Letter", style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: 10),
              LetterDropdownMenu(),
              // AlphabetGrid(),
              /// Uploaded Image
              SizedBox(
                height: 200,
                child: image == null ? Text("") : Image.file(image!),
              ),
              /// Upload Image Button
              if (!_isImageUploaded) // Show only if image is not uploaded
                ElevatedButton(
                  onPressed: chooseFromGallery,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade700),
                    padding: WidgetStatePropertyAll(EdgeInsets.only(
                      left: 15.0,
                      top: 10.0,
                      right: 15.0,
                      bottom: 10.0,
                    )),
                  ),
                  child: Text("Upload Image", style: Theme.of(context).textTheme.labelSmall),
                ),
              if (_isImageUploaded) // Show only if image is uploaded
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ImageSelection();
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
                  child: Text("Submit", style: Theme.of(context).textTheme.labelSmall),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LetterDropdownMenu extends StatefulWidget {
  const LetterDropdownMenu({super.key});

  @override
  State<LetterDropdownMenu> createState() => _LetterDropdownMenuState();
}

class _LetterDropdownMenuState extends State<LetterDropdownMenu> {
  String dropdownValue = alphabet.first;
  bool letterSelected = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          DropdownMenu<String>(
            textAlign: TextAlign.center,
            textStyle: Theme.of(context).textTheme.headlineSmall,
            menuStyle: MenuStyle(
              fixedSize: WidgetStatePropertyAll(const Size(130, 300)),
              alignment: Alignment.bottomLeft,
            ),
            initialSelection: alphabet.first,
            onSelected: (String? value) {
              print("$value selected!");
              letterSelected = true;
              setState(() {
                dropdownValue = value!;
              });
            },
            dropdownMenuEntries: alphabet.map<DropdownMenuEntry<String>>((String value) {
              return DropdownMenuEntry(
                value: value,
                label: value,
                style: ButtonStyle(
                  alignment: Alignment.center,
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 90.0)),
                  textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.titleLarge),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          letterSelected ? Text("You have selected $dropdownValue to upload.", style: Theme.of(context).textTheme.titleLarge) : Text(""),
        ],
      )
    );
  }
}

class AlphabetGrid extends StatelessWidget {
  const AlphabetGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 580,
      child: GridView.count(
        crossAxisSpacing: 10,
        crossAxisCount: 4,
        children: List.generate(26, (index) {
          String letter = alphabet.elementAt(index);
          return Center(
            child: ElevatedButton(
              onPressed: () {
                print('$letter pressed!');
              },
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.black),
                backgroundColor: WidgetStatePropertyAll(Colors.deepPurple.shade100),
              ),
              child: Text(letter, style: Theme.of(context).textTheme.titleLarge),
            ),
          );
        }),
      ),
    );
  }
}

