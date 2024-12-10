import 'package:flutter/material.dart';

class PredictionOverlay extends StatelessWidget {
  final String prediction;
  final Function(bool wasCorrect) onFeedback;

  const PredictionOverlay({
    Key? key,
    required this.prediction,
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => onFeedback(true),
                icon: const Icon(Icons.check),
                label: const Text('Correct'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () => onFeedback(false),
                icon: const Icon(Icons.close),
                label: const Text('Incorrect'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
