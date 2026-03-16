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

  print("Scanning for devices...");

  await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

  FlutterBluePlus.scanResults.listen((results) async {

    for (ScanResult r in results) {

      String name = r.device.platformName;

      print("Found device: $name");

      if (name == "UV_MONITOR") {

        print("UV monitor detected");

        await FlutterBluePlus.stopScan();

        connectedDevice = r.device;

        try {
          await connectedDevice!.connect();
        } catch (_) {}

        await _discoverServices(onData);

        break;
      }
    }
  });
}
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