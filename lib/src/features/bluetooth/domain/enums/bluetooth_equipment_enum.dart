part of 'bluetooth_enums.dart';

enum BluetoothEquipmentType {
  undefined,
  frequencyMeter,
  bikeGoper,
  bikeKeiser,
  treadmill,
}

extension BluetoothEquipmentTypeExtension on BluetoothEquipmentType {
  BluetoothConnectionType get getConnectionType {
    switch (this) {
      case BluetoothEquipmentType.bikeGoper:
        return BluetoothConnectionType.all;
      case BluetoothEquipmentType.bikeKeiser:
        return BluetoothConnectionType.broadcast;
      case BluetoothEquipmentType.treadmill:
        return BluetoothConnectionType.directConnect;
      case BluetoothEquipmentType.frequencyMeter:
        return BluetoothConnectionType.directConnect;
      default:
        return BluetoothConnectionType.na;
    }
  }
}
