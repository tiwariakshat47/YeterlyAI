// lib/screens/camera_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/asl_interpreter_service.dart';
import '../widgets/camera_controls.dart';
import '../widgets/prediction_overlay.dart';
import '../models/prediction_result.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late ASLInterpreterService _interpreter;
  bool _isInitialized = false;
  bool _isProcessing = false;
  PredictionResult? _currentPrediction;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeInterpreter();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _initializeInterpreter() async {
    _interpreter = ASLInterpreterService();
    await _interpreter.initialize();
  }

  Future<void> _processImage(XFile image) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final prediction = await _interpreter.processImage(File(image.path));
      if (mounted) {
        setState(() {
          _currentPrediction = prediction;
        });
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _captureAndProcess() async {
    if (!_controller.value.isInitialized) return;

    try {
      final image = await _controller.takePicture();
      await _processImage(image);
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  void _toggleStreaming() {
    setState(() {
      _isStreaming = !_isStreaming;
    });
    if (_isStreaming) {
      _startStreaming();
    }
  }

  Future<void> _startStreaming() async {
    while (_isStreaming) {
      await _captureAndProcess();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.dispose();
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
      ),
      body: Stack(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: CameraPreview(_controller),
          ),

          if (_currentPrediction != null)
            PredictionOverlay(
              prediction: _currentPrediction!.prediction,
              confidence: _currentPrediction!.confidence,
              onFeedback: (bool wasCorrect) {
                setState(() => _currentPrediction = null);
              },
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CameraControls(
              isStreaming: _isStreaming,
              isProcessing: _isProcessing,
              onCapture: _captureAndProcess,
              onStreamToggle: _toggleStreaming,
            ),
          ),
        ],
      ),
    );
  }
}
