part of 'bluetooth_enums.dart';

enum BluetoothEquipmentType {
  undefined,
  frequencyMeter,
  bikeGoper,
  bikeKeiser,
  treadmill,
}

extension BluetoothEquipmentTypeExtension on BluetoothEquipmentType {
  BluetoothCommunicationType get getCommunicationType {
    switch (this) {
      case BluetoothEquipmentType.bikeGoper:
        return BluetoothCommunicationType.all;
      case BluetoothEquipmentType.bikeKeiser:
        return BluetoothCommunicationType.broadcast;
      case BluetoothEquipmentType.treadmill:
        return BluetoothCommunicationType.directConnect;
      case BluetoothEquipmentType.frequencyMeter:
        return BluetoothCommunicationType.directConnect;
      default:
        return BluetoothCommunicationType.na;
    }
  }
}
