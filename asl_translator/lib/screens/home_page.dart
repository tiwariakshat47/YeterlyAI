// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../services/asl_interpreter_service.dart';
import '../models/prediction_result.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController _controller;
  bool _isInitialized = false;
  bool _isStreaming = false;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  late ASLInterpreterService _interpreter;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeInterpreter();
  }

  Future<void> _initializeInterpreter() async {
    _interpreter = ASLInterpreterService();
    await _interpreter.initialize();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
    );

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _processImage(String imagePath) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      print("Starting local processing...");
      final result = await _interpreter.processImage(File(imagePath));
      _showTranslationResult(result);
    } catch (e) {
      print("Error in _processImage: $e");
      _showError('Failed to process image: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _captureAndTranslate() async {
    try {
      print("Starting image capture");
      final XFile? image = await _controller.takePicture();
      if (image != null) {
        print("Image captured: ${image.path}");
        await _processImage(image.path);
      }
    } catch (e) {
      print("Error in _captureAndTranslate: $e");
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _pickAndTranslateImage() async {
    try {
      print("Starting image picker");
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print("Image picked: ${image.path}");
        await _processImage(image.path);
      }
    } catch (e) {
      print("Error in _pickAndTranslateImage: $e");
      _showError('Failed to pick image: $e');
    }
  }

  void _showTranslationResult(PredictionResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation Result'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Translation: ${result.prediction}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _buildRatingBar(result.prediction),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String translationId) {
    return Column(
      children: [
        const Text('How accurate was this translation?'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
                (index) => IconButton(
              icon: const Icon(Icons.star_border),
              onPressed: () => _submitRating(translationId, index + 1),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitRating(String translationId, int rating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('https://asl-backend-dsjk.onrender.com/api/survey'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'translation_id': translationId,
          'rating': rating,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _showSuccess('Thank you for your feedback!');
      }
    } catch (e) {
      _showError('Failed to submit rating: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ASL Translator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildCameraPreview(),
            ),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: CameraPreview(_controller),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _captureAndTranslate,
              icon: const Icon(Icons.camera),
              label: const Text('Capture'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _pickAndTranslateImage,
              icon: const Icon(Icons.image),
              label: const Text('Upload'),
            ),
          ),
        ],
      ),
    );
  }
}
