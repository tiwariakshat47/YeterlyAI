import 'package:flutter/material.dart';
import 'package:sign2text/utils/constants/image_strings.dart';
import 'package:sign2text/utils/helpers/helper_functions.dart';
import 'image_selection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class PredictionScreen extends StatefulWidget {
  final File image;

  const PredictionScreen({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  bool _isLoading = false;
  String _prediction = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _processPrediction();
  }

  Future<void> _processPrediction() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bytes = await widget.image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('https://asl-backend-dsjk.onrender.com/api/translate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'image': base64Image,
          'mode': 'prediction',
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        setState(() {
          _prediction = result['translation'];
        });
      } else {
        throw Exception('Failed to process image: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitFeedback(bool isCorrect) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();

      await http.post(
        Uri.parse('https://asl-backend-dsjk.onrender.com/api/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'prediction': _prediction,
          'isCorrect': isCorrect,
        }),
      );

      if (mounted) {
        AppHelperFunctions.showSnackBar(
          context,
          'Thank you for your feedback!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppHelperFunctions.showSnackBar(
          context,
          'Failed to submit feedback: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = AppHelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(dark ? AppImages.darkAppLogo : AppImages.lightAppLogo, height: 50.0),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.file(widget.image),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              )
            else
              Column(
                children: [
                  Text(
                    'Prediction: $_prediction',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('How is our prediction?'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () => _submitFeedback(true),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Correct'),
                              ),
                              TextButton.icon(
                                onPressed: () => _submitFeedback(false),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Incorrect'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const ImageSelection()),
                      (route) => false,
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
                alignment: Alignment.center,
                width: 100.0,
                child: Text("Predict", style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
