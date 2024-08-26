import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_names.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class BluetoothHelper {
  static BluetoothEquipmentType getBluetoothEquipmentType(
    DiscoveredDevice newDevice,
  ) {
    late BluetoothEquipmentType equipmentType;
    if (isBike(newDevice)) {
      final bool _isBikeKeiser = isBikeKeiser(newDevice);
      if (_isBikeKeiser) {
        equipmentType = BluetoothEquipmentType.bikeKeiser;
      } else {
        equipmentType = BluetoothEquipmentType.bikeGoper;
      }
    } else if (isTreadmill(newDevice)) {
      equipmentType = BluetoothEquipmentType.treadmill;
    } else if (isFrequencyMeter(newDevice)) {
      equipmentType = BluetoothEquipmentType.frequencyMeter;
    } else {
      equipmentType = BluetoothEquipmentType.undefined;
    }
    return equipmentType;
  }

  static List<Uuid> servicesFilterList() {
    return [
      // User Data
      BluetoothGuid.userDataService,
      // FitnessMachine - Bike & Treadmill
      BluetoothGuid.fitnessMachineService,
      // Frequency Meter
      BluetoothGuid.frequencyMeterService,
    ];
  }

  static bool isBike(DiscoveredDevice device) {
    if (_isBikeGoper(device) || isBikeKeiser(device)) {
      return true;
    }
    return false;
  }

  static bool _isBikeGoper(DiscoveredDevice device) {
    for (String name in BluetoothNames.bikesGoperNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }

  static bool isBikeKeiser(DiscoveredDevice device) {
    for (String name in BluetoothNames.bikesKeiserNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }

  static bool isTreadmill(DiscoveredDevice device) {
    for (String name in BluetoothNames.treadmillsNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }

  static bool isFrequencyMeter(DiscoveredDevice device) {
    for (String name in BluetoothNames.frequencyMetersNamesList) {
      if (device.name.contains(name)) return true;
    }
    return false;
  }
}
