import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothHelper {
  static List<Guid> servicesFilterList() {
    return [
      // User Data
      Guid('0000181c-0000-1000-8000-00805f9b34fb'),
      // FitnessMachine - Bike & Treadmill
      Guid('00001826-0000-1000-8000-00805f9b34fb'),
      //  Ziyou
      Guid('00001816-0000-1000-8000-00805f9b34fb'),
      // Frequency Meter
      Guid('0000180d-0000-1000-8000-00805f9b34fb'),
    ];
  }

  static bool treadmillValidation(BluetoothDevice device) {
    if (device.name.contains('i-Power+') ||
        device.name.contains('EQI-Treadmill') ||
        device.name.contains('Run')) {
      return true;
    }
    return false;
  }

  static bool frequencyMeterValidation(BluetoothDevice device) {
    if (device.name == 'mbeat') {
      return true;
    }
    return false;
  }

  static bool bikeValidation(BluetoothDevice device) {
    if (_bikeGoperValidation(device) || _bikeKeiserValidation(device)) {
      return true;
    }
    return false;
  }

  static bool _bikeGoperValidation(BluetoothDevice device) {
    if (device.name.contains('Goper Bike') || device.name.contains('BIKE-')) {
      return true;
    }
    return false;
  }

  static bool _bikeKeiserValidation(BluetoothDevice device) {
    if (device.name.contains('M3')) return true;
    return false;
  }
}
