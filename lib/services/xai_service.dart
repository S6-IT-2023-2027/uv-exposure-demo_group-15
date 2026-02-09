class XAIService {
  static final XAIService _instance = XAIService._internal();

  factory XAIService() {
    return _instance;
  }

  XAIService._internal();

  String generateExplanation({
    required double currentUV,
    required double cumulativeUV,
    required double threshold,
    required String feedback,
    required double previousThreshold,
  }) {
    // "Rule-based explainable decision logic with feature-level attribution"
    
    final StringBuffer explanation = StringBuffer();
    
    // 1. Analyze why alert happened (if threshold crossed)
    bool exceeded = cumulativeUV > threshold;
    
    if (exceeded) {
      explanation.writeln("Your UV exposure exceeded your learned safe limit.");
    } else {
      explanation.writeln("Your UV exposure is currently within safe limits.");
    }
    
    // 2. Feature Attribution (What contributed most?)
    // Simplified logic: Check if high intensity or long duration was more impactful
    // For dummy data, we'll assume a mix.
    
    if (currentUV > 6.0) {
      explanation.writeln("Most exposure occurred during peak sun hours (High UV Index).");
    } else {
      explanation.writeln("Exposure accumulated steadily over time.");
    }
    
    // 3. Historical Context / Feedback loop explanation
    if (feedback != 'None') {
      explanation.writeln("Similar exposure previously caused '$feedback' discomfort, so we adjusted your limit.");
    } else {
      explanation.writeln("You reported no issues previously, so your limit is stable.");
    }
    
    // 4. Threshold Change Context
    if (previousThreshold > threshold) {
       explanation.writeln("\n(Limit decreased from ${previousThreshold.toStringAsFixed(1)} to ${threshold.toStringAsFixed(1)} based on symptoms).");
    } else if (previousThreshold < threshold) {
       explanation.writeln("\n(Limit increased from ${previousThreshold.toStringAsFixed(1)} to ${threshold.toStringAsFixed(1)} as tolerance improves).");
    }

    return explanation.toString();
  }
}
