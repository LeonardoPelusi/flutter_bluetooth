import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';

abstract class BluetoothHelper {
  static BluetoothEquipmentType getBluetoothEquipmentType(
    BluetoothDevice newDevice,
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

  static List<String> getListOfAvailableEquipments() {
    return [
      ..._bikesNamesList,
      ..._treadmillsNamesList,
      ..._frequencyMetersNamesList,
    ];
  }

  static List<String> get _bikesNamesList {
    return [
      ..._bikesGoperNamesList,
      ..._bikesKeiserNamesList,
    ];
  }

  static List<String> get _bikesGoperNamesList {
    return [
      'Goper Bike',
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

  static bool isBike(BluetoothDevice device) {
    if (_isBikeGoper(device) || isBikeKeiser(device)) {
      return true;
    }
    return false;
  }

  static bool _isBikeGoper(BluetoothDevice device) {
    for (String name in _bikesGoperNamesList) {
      if (device.platformName.contains(name)) return true;
    }
    return false;
  }

  static bool isBikeKeiser(BluetoothDevice device) {
    for (String name in _bikesKeiserNamesList) {
      if (device.platformName.contains(name)) return true;
    }
    return false;
  }

  static bool isTreadmill(BluetoothDevice device) {
    for (String name in _treadmillsNamesList) {
      if (device.platformName.contains(name)) return true;
    }
    return false;
  }

  static bool isFrequencyMeter(BluetoothDevice device) {
    for (String name in _frequencyMetersNamesList) {
      if (device.platformName.contains(name)) return true;
    }
    return false;
  }
}
