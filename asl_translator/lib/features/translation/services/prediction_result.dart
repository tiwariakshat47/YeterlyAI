class PredictionResult {
  final String translation;
  final double confidence;
  final String translationId;
  final String prediction; // Added for backward compatibility

  PredictionResult({
    required this.translation,
    required this.confidence,
    required this.translationId,
  }) : prediction = translation; // Set prediction to same value as translation

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      translation: json['translation'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      translationId: json['translation_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'translation': translation,
    'confidence': confidence,
    'translation_id': translationId,
  };
}
