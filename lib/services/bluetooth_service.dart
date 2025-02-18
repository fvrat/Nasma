import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  // Start scanning for Bluetooth devices
  Stream<List<ScanResult>> scanForDevices() async* {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    yield* FlutterBluePlus.scanResults;
    await Future.delayed(const Duration(seconds: 5)); // Allow scanning time
    FlutterBluePlus.stopScan();
  }

  // Connect to a Bluetooth device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {
      if (e.toString().contains('already connected')) {
        print("Device already connected.");
      } else {
        print("Error connecting: $e");
      }
    }
  }

  // Disconnect from a Bluetooth device
  Future<void> disconnectDevice(BluetoothDevice device) async {
    await device.disconnect();
  }
}
