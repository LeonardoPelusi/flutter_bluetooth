part of 'bluetooth_equipment_bloc.dart';

@immutable
sealed class BluetoothEquipmentEvent {}

class BluetoothEquipmentInitialEvent extends BluetoothEquipmentEvent {}

class BluetoothEquipmentConnectEvent extends BluetoothEquipmentEvent {
  final BluetoothEquipmentModel deviceWithId;
  final bool resetRetries;
  BluetoothEquipmentConnectEvent({
    required this.deviceWithId,
    required this.resetRetries,
  });
}

class BluetoothEquipmentConnectBike extends BluetoothEquipmentEvent {
  final BluetoothEquipmentModel equipment;
  BluetoothEquipmentConnectBike({
    required this.equipment,
  });
}

class BluetoothEquipmentConnectTreadmill extends BluetoothEquipmentEvent {
  final BluetoothEquipmentModel equipment;
  BluetoothEquipmentConnectTreadmill({
    required this.equipment,
  });
}

class BluetoothEquipmentConnectFrequencyMeter extends BluetoothEquipmentEvent {
  final BluetoothEquipmentModel equipment;
  BluetoothEquipmentConnectFrequencyMeter({
    required this.equipment,
  });
}

class BluetoothEquipmentDisconnectEvent extends BluetoothEquipmentEvent {}
