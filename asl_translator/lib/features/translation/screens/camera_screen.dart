import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../shared/widgets/settings_drawer.dart';
import '../services/prediction_result.dart';
import '../services/asl_interpreter_service.dart';
import '../../shared/widgets/camera_controls.dart';
import '../../shared/widgets/prediction_overlay.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late CameraController _controller;
  late ASLInterpreterService _interpreter;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isStreaming = false;
  PredictionResult? _currentPrediction;

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
      _showError('Error initializing camera: $e');
    }
  }

  Future<void> _initializeInterpreter() async {
    _interpreter = ASLInterpreterService();
    await _interpreter.initialize();
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
      _showError('Error processing image: $e');
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
      _showError('Error capturing image: $e');
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

  void _handlePredictionFeedback(bool wasCorrect) {
    // Here you would typically send feedback to your backend
    setState(() {
      _currentPrediction = null;
    });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _key.currentState?.openEndDrawer(),
          ),
        ],
      ),
      key: _key,
      endDrawer: const SettingsDrawer(),
      body: Stack(
        children: [
          // Camera Preview
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: CameraPreview(_controller),
          ),

          // Prediction Overlay
          if (_currentPrediction != null)
            Positioned.fill(
              child: PredictionOverlay(
                prediction: _currentPrediction!.translation,
                onFeedback: _handlePredictionFeedback,
              ),
            ),

          // Camera Controls
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
