import 'package:flutter/material.dart';
import '../models/prediction_result.dart';

class PredictionOverlay extends StatelessWidget {
  final String prediction;
  final double confidence;
  final Function(bool wasCorrect) onFeedback;

  const PredictionOverlay({
    Key? key,
    required this.prediction,
    required this.confidence,
    required this.onFeedback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Prediction: $prediction',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => onFeedback(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Correct'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => onFeedback(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Incorrect'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
