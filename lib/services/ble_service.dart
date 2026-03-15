import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {

  final FlutterBluePlus flutterBlue = FlutterBluePlus();

  BluetoothDevice? connectedDevice;

  final serviceUUID = Guid("12345678-1234-1234-1234-123456789abc");
  final uvCharacteristicUUID = Guid("abcd");
  final thresholdCharacteristicUUID = Guid("efgh");

  BluetoothCharacteristic? uvCharacteristic;
  BluetoothCharacteristic? thresholdCharacteristic;

  /// Scan and connect to ESP32
  Future<void> startScan(Function(String) onData) async {

    flutterBlue.startScan(timeout: const Duration(seconds: 5));

    flutterBlue.scanResults.listen((results) async {

      for (ScanResult r in results) {

        if (r.device.platformName == "UV_Monitor") {

          flutterBlue.stopScan();

          connectedDevice = r.device;

          await connectedDevice!.connect();

          await _discoverServices(onData);

        }

      }

    });

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