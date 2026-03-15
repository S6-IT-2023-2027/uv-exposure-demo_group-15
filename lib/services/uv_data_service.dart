import 'dart:async';

/// UV data accumulation service.
///
/// Receives real UV index values pushed by the BLE service (originating from
/// the GUVA-S12SD sensor on the ESP32) and accumulates a daily exposure total.
///
/// The simulated timer has been removed.  Data now flows:
///   BLEService.onData callback → [updateFromBLE] → streams → UI
///
/// Integration interval: the ESP32 sends a reading every 5 seconds, so the
/// integration step uses a 5-second window (5 / 3600 h) to keep cumulative
/// units consistent with UV-index·hours.
class UVDataService {
  // Singleton
  static final UVDataService _instance = UVDataService._internal();

  factory UVDataService() => _instance;

  UVDataService._internal();

  // ─── State ────────────────────────────────────────────────────────────────

  double _currentUV = 0.0;
  double _cumulativeUV = 0.0;

  // BLE sends every 5 seconds → integration window in hours
  static const double _integrationStepHours = 5.0 / 3600.0;

  // ─── Streams ───────────────────────────────────────────────────────────────

  final _uvController = StreamController<double>.broadcast();
  final _cumulativeController = StreamController<double>.broadcast();

  Stream<double> get uvStream => _uvController.stream;
  Stream<double> get cumulativeStream => _cumulativeController.stream;

  double get currentUV => _currentUV;
  double get cumulativeUV => _cumulativeUV;

  // ─── BLE data entry point ─────────────────────────────────────────────────

  /// Called by [BLEService] whenever a new UV value arrives from the ESP32.
  ///
  /// [rawData] is the UTF-8 string sent over BLE (e.g. "7.3" or "5").
  /// Invalid / non-numeric strings are silently ignored.
  void updateFromBLE(String rawData) {
    final double? parsed = double.tryParse(rawData.trim());
    if (parsed == null || parsed < 0) return; // guard against malformed data

    _currentUV = parsed;

    // Accumulate: UV index × time-window (hours) → UV-index·hours
    _cumulativeUV += _currentUV * _integrationStepHours;

    _uvController.add(_currentUV);
    _cumulativeController.add(_cumulativeUV);
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  /// Reset the daily cumulative total (call at the start of each new day or
  /// after the user completes their daily check-in).
  void reset() {
    _cumulativeUV = 0.0;
    _cumulativeController.add(_cumulativeUV);
  }

  void dispose() {
    _uvController.close();
    _cumulativeController.close();
  }
}
