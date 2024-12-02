import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/prediction_result.dart';

class ASLInterpreterService {
  static const int inputSize = 200;
  static const int numClasses = 29;
  late final Interpreter _interpreter;
  static final ASLInterpreterService _instance = ASLInterpreterService._internal();

  final List<String> labels = [
    'E', 'H', 'O', 'T', 'B', 'X', 'NOTHING', 'S', 'A', 'I',
    'G', 'K', 'DEL', 'Q', 'F', 'Z', 'L', 'C', 'W', 'J',
    'R', 'Y', 'U', 'P', 'V', 'N', 'M', 'SPACE', 'D'
  ];

  factory ASLInterpreterService() {
    return _instance;
  }

  ASLInterpreterService._internal();

  Future<void> initialize() async {
    try {
      final options = InterpreterOptions()..threads = 4;

      _interpreter = await Interpreter.fromAsset(
          'android/app/src/main/assets/asl_model.tflite',
          options: options
      );

      print('ASL Interpreter initialized successfully');

      // Print input/output details
      final inputShape = _interpreter.getInputTensor(0).shape;
      final outputShape = _interpreter.getOutputTensor(0).shape;
      print('Model input shape: $inputShape');
      print('Model output shape: $outputShape');
    } catch (e) {
      print('Error initializing interpreter: $e');
      rethrow;
    }
  }

  Future<PredictionResult> processImage(File imageFile) async {
    try {
      print("Starting image processing...");

      // Read and decode image
      final bytes = await imageFile.readAsBytes();
      print("Image bytes read: ${bytes.length}");

      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');
      print("Image decoded successfully: ${image.width}x${image.height}");

      // Resize to model input size
      final resized = img.copyResize(
          image,
          width: inputSize,
          height: inputSize,
          interpolation: img.Interpolation.linear
      );

      print("Image resized to ${inputSize}x${inputSize}");

      // Prepare input tensor [1, height, width, 3]
      var input = List.filled(1 * inputSize * inputSize * 3, 0.0);

      int pixelIndex = 0;
      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          // Normalize RGB values to [-1, 1]
          input[pixelIndex] = (pixel[0] - 127.5) / 127.5;     // R
          input[pixelIndex + 1] = (pixel[1] - 127.5) / 127.5; // G
          input[pixelIndex + 2] = (pixel[2] - 127.5) / 127.5; // B
          pixelIndex += 3;
        }
      }

      // Reshape to required dimensions [1, height, width, 3]
      var inputArray = input.reshape([1, inputSize, inputSize, 3]);
      print("Input tensor prepared with shape: [1, $inputSize, $inputSize, 3]");

      // Prepare output tensor
      var outputArray = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);

      // Run inference
      print("Starting model inference...");
      _interpreter.run(inputArray, outputArray);
      print("Model inference completed");

      // Get top predictions
      print("\nRaw output values:");
      var indexed = List.generate(numClasses, (i) => MapEntry(i, outputArray[0][i]))
        ..sort((a, b) => b.value.compareTo(a.value));

      print("Top 5 predictions:");
      for (var i = 0; i < 5; i++) {
        var prob = indexed[i].value;
        var label = labels[indexed[i].key];
        print("  $label: ${(prob * 100).toStringAsFixed(2)}%");
      }

      return PredictionResult(
        prediction: labels[indexed[0].key],
        confidence: indexed[0].value,
      );

    } catch (e) {
      print('Error processing image: $e');
      rethrow;
    }
  }

  void dispose() {
    try {
      _interpreter.close();
      print('Interpreter disposed successfully');
    } catch (e) {
      print('Error disposing interpreter: $e');
    }
  }
}
