import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'prediction_result.dart';

class ASLInterpreterService {
  static const int inputSize = 224;
  static const int numClasses = 26;
  late final Interpreter _interpreter;
  static final ASLInterpreterService _instance = ASLInterpreterService._internal();

  factory ASLInterpreterService() {
    return _instance;
  }

  ASLInterpreterService._internal();

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('android/app/src/main/assets/asl_model.tflite');
      print('ASL Interpreter initialized successfully');
    } catch (e) {
      print('Error initializing interpreter: $e');
      rethrow;
    }
  }

  Future<PredictionResult> processImage(File imageFile) async {
    try {
      print("Starting image processing...");

      final bytes = await imageFile.readAsBytes();
      print("Image bytes read: ${bytes.length}");

      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');
      print("Image decoded successfully: ${image.width}x${image.height}");

      final resizedImage = img.copyResize(image, width: inputSize, height: inputSize);
      print("Image resized to ${inputSize}x${inputSize}");

      var input = List.generate(
        1,
            (index) => List.generate(
          inputSize,
              (y) => List.generate(
            inputSize,
                (x) => List.generate(
              3,
                  (c) => resizedImage.getPixel(x, y)[c] / 255.0,
            ),
          ),
        ),
      );
      print("Input tensor prepared");

      var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);
      print("Output tensor allocated");

      print("Starting model inference...");
      _interpreter.run(input, output);
      print("Model inference completed");

      var maxScore = 0.0;
      var predictedClass = 0;

      for (var i = 0; i < numClasses; i++) {
        if (output[0][i] > maxScore) {
          maxScore = output[0][i];
          predictedClass = i;
        }
      }

      final result = String.fromCharCode(predictedClass + 65);
      print("Predicted letter: $result with confidence: ${maxScore * 100}%");

      return PredictionResult(
        translation: result,
        confidence: maxScore,
        translationId: DateTime.now().millisecondsSinceEpoch.toString(),
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
