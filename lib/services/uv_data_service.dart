import 'dart:async';
import 'dart:math';

class UVDataService {
  static final UVDataService _instance = UVDataService._internal();

  factory UVDataService() {
    return _instance;
  }

  UVDataService._internal();

  // Observable values
  double _currentUV = 0.0;
  double _cumulativeUV = 0.0;

  // Stream controllers to broadcast updates
  final _uvController = StreamController<double>.broadcast();
  final _cumulativeController = StreamController<double>.broadcast();

  Stream<double> get uvStream => _uvController.stream;
  Stream<double> get cumulativeStream => _cumulativeController.stream;

  double get currentUV => _currentUV;
  double get cumulativeUV => _cumulativeUV;

  Timer? _timer;
  final Random _random = Random();

  void startService() {
    if (_timer != null && _timer!.isActive) return;

    // Simulate UV data updates every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateUVData();
    });
  }

  void stopService() {
    _timer?.cancel();
  }

  void _updateUVData() {
    // Simulate UV Index fluctuation (e.g., between 0 and 11+)
    // For demo purposes, we'll keep it somewhat realistic for a sunny day
    // Base value around 5.0, fluctuating +/- 2.0
    double fluctuation = (_random.nextDouble() * 4.0) - 2.0; // -2.0 to 2.0
    double newValue = 5.0 + fluctuation;
    
    // Ensure positive value
    _currentUV = newValue < 0 ? 0 : double.parse(newValue.toStringAsFixed(1));
    
    // Update cumulative UV (simple integration simulation)
    // Adding a fraction of current UV to cumulative
    _cumulativeUV += (_currentUV * 0.1); 

    // Broadcast updates
    _uvController.add(_currentUV);
    _cumulativeController.add(_cumulativeUV);
  }

  void reset() {
    _cumulativeUV = 0.0;
    _cumulativeController.add(_cumulativeUV);
  }
  
  void dispose() {
    _uvController.close();
    _cumulativeController.close();
    _timer?.cancel();
  }
}
