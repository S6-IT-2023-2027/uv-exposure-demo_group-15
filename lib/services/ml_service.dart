import 'package:shared_preferences/shared_preferences.dart';

class AdaptiveThresholdService {
  static final AdaptiveThresholdService _instance = AdaptiveThresholdService._internal();

  factory AdaptiveThresholdService() {
    return _instance;
  }

  AdaptiveThresholdService._internal();

  double _dailySafeExposureLimit = 100.0; // Default generic unit

  double get dailySafeExposureLimit => _dailySafeExposureLimit;

  // Keys for SharedPreferences
  static const String _thresholdKey = 'daily_safe_exposure_limit';

  Future<void> initialize(int skinTypeScore) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we have a stored threshold
    if (prefs.containsKey(_thresholdKey)) {
      _dailySafeExposureLimit = prefs.getDouble(_thresholdKey) ?? 100.0;
    } else {
      // Calculate initial threshold based on skin type score (dummy logic)
      // Score 0-10 -> Type I/II (Lower threshold)
      // Score 11-20 -> Type III/IV (Medium threshold)
      // Score 21+ -> Type V/VI (Higher threshold)
      
      if (skinTypeScore <= 10) {
        _dailySafeExposureLimit = 50.0;
      } else if (skinTypeScore <= 20) {
        _dailySafeExposureLimit = 100.0;
      } else {
        _dailySafeExposureLimit = 150.0;
      }
      
      await _saveThreshold();
    }
  }

  Future<void> updateThreshold(String feedbackLevel) async {
    // logical increments/decrements based on feedback
    // Feedback levels: "None", "Mild", "Moderate", "Severe"
    
    double adjustmentFactor = 1.0;

    switch (feedbackLevel) {
      case 'None':
        // Increase slightly (+5%) if no symptoms
        adjustmentFactor = 1.05;
        break;
      case 'Mild':
        // Decrease small amount (-5%)
        adjustmentFactor = 0.95;
        break;
      case 'Moderate':
        // Decrease moderately (-15%)
        adjustmentFactor = 0.85;
        break;
      case 'Severe':
        // Decrease significantly (-30%)
        adjustmentFactor = 0.70;
        break;
      default:
        adjustmentFactor = 1.0;
    }

    _dailySafeExposureLimit *= adjustmentFactor;
    
    // Ensure it doesn't drop too low or go insanely high
    if (_dailySafeExposureLimit < 10.0) _dailySafeExposureLimit = 10.0;
    if (_dailySafeExposureLimit > 500.0) _dailySafeExposureLimit = 500.0;

    await _saveThreshold();
  }

  Future<void> _saveThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_thresholdKey, _dailySafeExposureLimit);
  }
}
