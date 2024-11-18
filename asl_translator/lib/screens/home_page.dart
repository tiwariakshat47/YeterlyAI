// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _processImage(String imagePath, String mode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('User not authenticated');
        return;
      }

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/translate'), // Android emulator localhost
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'image': base64Image,
          'mode': mode,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        _showTranslationResult(result);
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to process image: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _captureAndTranslate() async {
    try {
      final XFile? image = await _controller.takePicture();
      if (image != null) {
        await _processImage(image.path, 'capture');
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _pickAndTranslateImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(image.path, 'upload');
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _showTranslationResult(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Translation Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Translation: ${result['translation']}'),
            Text(
                'Confidence: ${(result['confidence'] * 100).toStringAsFixed(1)}%'
            ),
            const SizedBox(height: 20),
            _buildRatingBar(result['translation_id']),
          ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: const Icon(Icons.star_border),
              onPressed: () => _submitRating(translationId, index + 1),
            );
          }),
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
        Uri.parse('http://10.0.2.2:5000/api/survey'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'translation_id': translationId,
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _showSuccess('Thank you for your feedback!');
      }
    } catch (e) {
      _showError('Failed to submit rating: $e');
    }
  }

  Future<void> _toggleStreaming() async {
    setState(() => _isStreaming = !_isStreaming);

    if (_isStreaming) {
      _startStreaming();
    }
  }

  Future<void> _startStreaming() async {
    while (_isStreaming) {
      try {
        final XFile image = await _controller.takePicture();
        await _processImage(image.path, 'stream');
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        _showError('Streaming error: $e');
        setState(() => _isStreaming = false);
        break;
      }
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
      body: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _captureAndTranslate,
                    icon: const Icon(Icons.camera),
                    label: const Text('Capture'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _toggleStreaming,
                    icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
                    label: Text(_isStreaming ? 'Stop Stream' : 'Start Stream'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isStreaming ? Colors.red : null,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickAndTranslateImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Upload'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}