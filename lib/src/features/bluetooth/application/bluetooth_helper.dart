import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';

abstract class BluetoothHelper {
  static List<Guid> servicesFilterList() {
    return [
      // User Data
      BluetoothEquipmentService.guids.userDataService,
      // FitnessMachine - Bike & Treadmill
      BluetoothEquipmentService.guids.fitnessMachineService,
      // Frequency Meter
      BluetoothEquipmentService.guids.frequencyMeterService,
    ];
  }

  static bool isTreadmill(BluetoothDevice device) {
    if (device.name.contains('i-Power+') ||
        device.name.contains('EQI-Treadmill') ||
        device.name.contains('Run')) {
      return true;
    }
    return false;
  }

  static bool isFrequencyMeter(BluetoothDevice device) {
    if (device.name == 'mbeat') {
      return true;
    }
    return false;
  }

  static bool isBike(BluetoothDevice device) {
    if (_isBikeGoper(device) || isBikeKeiser(device)) {
      return true;
    }
    return false;
  }

  static bool _isBikeGoper(BluetoothDevice device) {
    if (device.name.contains('Goper Bike') || device.name.contains('BIKE-')) {
      return true;
    }
    return false;
  }

  static bool isBikeKeiser(BluetoothDevice device) {
    if (device.name.contains('M3')) return true;
    return false;
  }
}
