import 'package:shared_preferences/shared_preferences.dart';

/// Online adaptive threshold learning service.
///
/// Maintains [dailySafeExposureLimit] — the personalised UV exposure budget
/// for the user.  The threshold is updated incrementally after each daily
/// feedback cycle and persisted via SharedPreferences so learning carries
/// over across app sessions.
///
/// Update rules (fixed-delta, as per spec):
///   "None"     → threshold + 5   (no symptoms → widen budget)
///   "Mild"     → threshold − 5   (slight pinkness → tighten slightly)
///   "Moderate" → threshold − 10  (visible burn → tighten more)
///   "Severe"   → threshold − 20  (painful burn → tighten significantly)
///
/// Constraints: threshold is always clamped to [40, 200].
class AdaptiveThresholdService {
  // Singleton
  static final AdaptiveThresholdService _instance =
      AdaptiveThresholdService._internal();

  factory AdaptiveThresholdService() => _instance;

  AdaptiveThresholdService._internal();

  // ─── State ────────────────────────────────────────────────────────────────

  /// Current personalised daily safe UV exposure limit.
  double dailySafeExposureLimit = 100.0;

  static const String _thresholdKey = 'daily_safe_exposure_limit';

  // Clamp bounds (as per spec)
  static const double _minThreshold = 40.0;
  static const double _maxThreshold = 200.0;

  // ─── Initialisation ────────────────────────────────────────────────────────

  /// Load a previously persisted threshold, or seed from [skinTypeScore].
  ///
  /// Call once after questionnaire completion.
  Future<void> initialize(int skinTypeScore) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_thresholdKey)) {
      // Restore persisted learning state
      dailySafeExposureLimit =
          prefs.getDouble(_thresholdKey) ?? 100.0;
    } else {
      // First-run seed based on Fitzpatrick skin-type score
      //   Score  0-10  → Type I/II   → conservative start (50)
      //   Score 11-20  → Type III/IV → medium start       (100)
      //   Score  21+   → Type V/VI   → higher start       (150)
      if (skinTypeScore <= 10) {
        dailySafeExposureLimit = 50.0;
      } else if (skinTypeScore <= 20) {
        dailySafeExposureLimit = 100.0;
      } else {
        dailySafeExposureLimit = 150.0;
      }

      await _persist();
    }
  }

  // ─── Core ML update ────────────────────────────────────────────────────────

  /// Apply one incremental update step and return the **new** threshold.
  ///
  /// Parameters:
  ///   [cumulativeExposure] — today's total accumulated UV exposure (from
  ///     BLE/sensor data).  Stored for future audit / logging but not used
  ///     in the delta calculation itself (the feedback signal carries the
  ///     symptom-level information).
  ///   [feedback] — user-reported symptom level after the day.
  ///     Accepted values: "None" | "Mild" | "Moderate" | "Severe"
  ///
  /// Returns the updated [dailySafeExposureLimit].
  double updateThreshold(double cumulativeExposure, String feedback) {
    // Fixed-delta rules (spec §1)
    double delta;
    switch (feedback) {
      case 'None':
        delta = 5.0;   // increase slightly — user tolerated the exposure
        break;
      case 'Mild':
        delta = -5.0;  // decrease slightly
        break;
      case 'Moderate':
        delta = -10.0; // decrease more
        break;
      case 'Severe':
        delta = -20.0; // decrease significantly
        break;
      default:
        delta = 0.0;   // unknown feedback → no change
    }

    dailySafeExposureLimit = (dailySafeExposureLimit + delta)
        .clamp(_minThreshold, _maxThreshold);

    // Persist asynchronously — fire-and-forget is fine here
    _persist();

    return dailySafeExposureLimit;
  }

  // ─── Persistence ───────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_thresholdKey, dailySafeExposureLimit);
  }

  /// Hard-reset the threshold (useful for testing / onboarding re-run).
  Future<void> reset() async {
    dailySafeExposureLimit = 100.0;
    await _persist();
  }
}
