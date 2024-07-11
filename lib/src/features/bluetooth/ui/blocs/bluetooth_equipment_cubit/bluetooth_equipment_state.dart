part of 'bluetooth_equipment_cubit.dart';

abstract class BluetoothEquipmentState {
  final List<DeviceWithId> connectingEquipments;
  BluetoothEquipmentState({
    this.connectingEquipments = const [],
  });
}

class BluetoothEquipmentInitial extends BluetoothEquipmentState {}

class BluetoothEquipmentConnecting extends BluetoothEquipmentState {
  BluetoothEquipmentConnecting({
    required List<DeviceWithId> connectingEquipments,
  }) : super(connectingEquipments: connectingEquipments);
}

class BluetoothEquipmentConnected extends BluetoothEquipmentState {}

class BluetoothEquipmentError extends BluetoothEquipmentState {
  final String error;
  BluetoothEquipmentError({
    required this.error,
  });
}

class BluetoothEquipmentTimeExpiredError extends BluetoothEquipmentState {
  final String error;
  BluetoothEquipmentTimeExpiredError({
    required this.error,
  });
}
