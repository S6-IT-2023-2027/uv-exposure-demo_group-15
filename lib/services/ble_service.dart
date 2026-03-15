import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {

  BluetoothDevice? connectedDevice;

  final serviceUUID =
    Guid("12345678-1234-1234-1234-123456789abc");

final uvCharacteristicUUID =
    Guid("0000abcd-0000-1000-8000-00805f9b34fb");

final thresholdCharacteristicUUID =
    Guid("0000ef01-0000-1000-8000-00805f9b34fb");

  BluetoothCharacteristic? uvCharacteristic;
  BluetoothCharacteristic? thresholdCharacteristic;

  bool _isConnecting = false;

  /// Scan and connect to ESP32
  Future<void> startScan(Function(String) onData) async {
    if (_isConnecting) return;

    print("Starting BLE scan...");

    // 1. Setup listener FIRST before blocking the thread with await!
    // (If you await startScan first, it halts the entire connection response for 10 seconds empty-handed)
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        
        // Detect ESP32 by name instantly as the broadcasts come in
        if (r.advertisementData.advName == "UV_Monitor") {
          
          if (_isConnecting) return; // Prevent dual-firing the connect sequence
          _isConnecting = true;
          
          print("UV Monitor detected instantly!");

          await FlutterBluePlus.stopScan();

          connectedDevice = r.device;

          try {
            await connectedDevice!.connect();
          } catch (_) {
            _isConnecting = false;
            return;
          }

          // Monitor for accidental drops and auto-reconnect
          connectedDevice!.connectionState.listen((state) {
            if (state == BluetoothConnectionState.disconnected) {
              print("Device disconnected. Auto-reconnecting...");
              _isConnecting = false;
              startScan(onData);
            }
          });

          await _discoverServices(onData);
          break;
        }
      }
    });

    // 2. Fire the scan now that the net is listening
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (_) {}
    
    // Optional: if the 10 seconds elapsed without finding the ESP32, loop the scan.
    if (!_isConnecting) {
      startScan(onData);
    }
  }

  /// Discover BLE services
  Future<void> _discoverServices(Function(String) onData) async {

    List<BluetoothService> services =
        await connectedDevice!.discoverServices();

    for (BluetoothService service in services) {

      if (service.uuid == serviceUUID) {

        for (BluetoothCharacteristic c in service.characteristics) {

          if (c.uuid == uvCharacteristicUUID) {

            uvCharacteristic = c;

            await c.setNotifyValue(true);

            c.lastValueStream.listen((value) {

              String uv = String.fromCharCodes(value);

              onData(uv);

            });

          }

          if (c.uuid == thresholdCharacteristicUUID) {

            thresholdCharacteristic = c;

          }

        }

      }

    }

  }

  /// Send adaptive threshold to ESP32
  Future<void> sendThreshold(double threshold) async {

    if (thresholdCharacteristic == null) return;

    List<int> data = threshold.toString().codeUnits;

    await thresholdCharacteristic!.write(data);

  }

  /// Optional cleanup
  Future<void> disconnect() async {

    await connectedDevice?.disconnect();

  }

}