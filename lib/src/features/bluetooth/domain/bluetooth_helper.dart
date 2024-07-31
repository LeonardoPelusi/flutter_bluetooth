import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class BluetoothHelper {
  static BluetoothEquipmentType getBluetoothEquipmentType(
    DiscoveredDevice newDevice,
  ) {
    late BluetoothEquipmentType equipmentType;
    if (BluetoothHelper.isBike(newDevice)) {
      final bool isBikeKeiser = BluetoothHelper.isBikeKeiser(newDevice);
      if (isBikeKeiser) {
        equipmentType = BluetoothEquipmentType.bikeKeiser;
      } else {
        equipmentType = BluetoothEquipmentType.bikeGoper;
      }
    } else if (BluetoothHelper.isTreadmill(newDevice)) {
      equipmentType = BluetoothEquipmentType.treadmill;
    } else if (BluetoothHelper.isFrequencyMeter(newDevice)) {
      equipmentType = BluetoothEquipmentType.frequencyMeter;
    } else {
      equipmentType = BluetoothEquipmentType.undefined;
    }
    return equipmentType;
  }

  static List<Uuid> servicesFilterList() {
    return [
      // User Data
      BluetoothEquipmentService.guids.userDataService,
      // FitnessMachine - Bike & Treadmill
      BluetoothEquipmentService.guids.fitnessMachineService,
      // Frequency Meter
      BluetoothEquipmentService.guids.frequencyMeterService,
    ];
  }

  static bool isBike(DiscoveredDevice device) {
    if (_isBikeGoper(device) || isBikeKeiser(device)) {
      return true;
    }
    return false;
  }

  static bool _isBikeGoper(DiscoveredDevice device) {
    for (String name in _bikesGoperNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }

  static bool isBikeKeiser(DiscoveredDevice device) {
    for (String name in _bikesKeiserNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }

  static bool isTreadmill(DiscoveredDevice device) {
    for (String name in _treadmillsNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }

  static bool isFrequencyMeter(DiscoveredDevice device) {
    for (String name in _frequencyMetersNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }

  static List<String> get _bikesGoperNamesList {
    return [
      'Goper Bike          ',
      'BIKE-',
    ];
  }

  static List<String> get _bikesKeiserNamesList {
    return [
      'M3',
    ];
  }

  static List<String> get _treadmillsNamesList {
    return [
      'i-Power+',
      'EQI-Treadmill',
      'Goper Run',
    ];
  }

  static List<String> get _frequencyMetersNamesList {
    return [
      'mbeat',
    ];
  }
}
