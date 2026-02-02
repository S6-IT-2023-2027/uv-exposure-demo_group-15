/// Manages the logic for determining and updating the user's UV threshold.
class ThresholdLogic {
  
  /// Returns initial threshold based on questionnaire answer index (0-4).
  /// 0: Always burns (Sensitive) -> Low threshold
  /// 4: Never burns (Resilient) -> High threshold
  static int getInitialThreshold(int answerIndex) {
    switch (answerIndex) {
      case 0: return 50;  // Very Sensitive
      case 1: return 80;  // Sensitive
      case 2: return 120; // Moderate
      case 3: return 160; // High
      case 4: return 200; // Very High
      default: return 100;
    }
  }

  /// Adjusts threshold based on user feedback.
  /// feedbackIndex: 0 (None), 1 (Mild), 2 (Moderate), 3 (Severe)
  static int adjustThreshold(int currentThreshold, int feedbackIndex) {
    switch (feedbackIndex) {
      case 0: // No discomfort
        // Increase slightly to allow more exposure next time (adaptation)
        return (currentThreshold * 1.05).round(); 
      case 1: // Mild
        // Small decrease
        return (currentThreshold * 0.90).round();
      case 2: // Moderate
        // Meaningful decrease
        return (currentThreshold * 0.75).round();
      case 3: // Severe
        // Strong decrease to prevent injury
        return (currentThreshold * 0.50).round();
      default:
        return currentThreshold;
    }
  }
}
