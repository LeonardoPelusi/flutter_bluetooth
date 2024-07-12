part of 'bluetooth_equipment_bloc.dart';

@immutable
sealed class BluetoothEquipmentEvent {}

class BluetoothEquipmentInitialEvent extends BluetoothEquipmentEvent {}

class BluetoothEquipmentConnectEvent extends BluetoothEquipmentEvent {
  final BluetoothEquipmentModel bluetoothEquipment;
  final bool resetRetries;
  BluetoothEquipmentConnectEvent({
    required this.bluetoothEquipment,
    required this.resetRetries,
  });
}

class BluetoothEquipmentConnectBikeEvent extends BluetoothEquipmentEvent {
  final BluetoothDevice equipment;
  BluetoothEquipmentConnectBikeEvent({
    required this.equipment,
  });
}

class BluetoothEquipmentConnectTreadmillEvent extends BluetoothEquipmentEvent {
  final BluetoothDevice equipment;
  BluetoothEquipmentConnectTreadmillEvent({
    required this.equipment,
  });
}

class BluetoothEquipmentConnectFrequencyMeterEvent extends BluetoothEquipmentEvent {
  final BluetoothDevice equipment;
  BluetoothEquipmentConnectFrequencyMeterEvent({
    required this.equipment,
  });
}

class BluetoothEquipmentDisconnectEvent extends BluetoothEquipmentEvent {
  final BluetoothEquipmentModel bluetoothEquipment;
  BluetoothEquipmentDisconnectEvent({
    required this.bluetoothEquipment,
  });
}

class BluetoothEquipmentDisconnectBikeEvent extends BluetoothEquipmentEvent {}

class BluetoothEquipmentDisconnectTreadmillEvent extends BluetoothEquipmentEvent {}

class BluetoothEquipmentDisconnectFrequencyMeterEvent
    extends BluetoothEquipmentEvent {}
