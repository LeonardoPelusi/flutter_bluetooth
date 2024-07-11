part of 'bluetooth_equipments_bloc.dart';

@immutable
sealed class BluetoothEquipmentsState {}

final class BluetoothEquipmentsInitialState extends BluetoothEquipmentsState {}

final class BluetoothEquipmentsListLoadingState extends BluetoothEquipmentsState {}

final class BluetoothEquipmentsListAddEquipmentState extends BluetoothEquipmentsState {
  final BluetoothEquipmentModel bluetoothEquipment;

  BluetoothEquipmentsListAddEquipmentState({
    required this.bluetoothEquipment,
  });
}

final class BluetoothEquipmentsBackgroundListLoadedState
    extends BluetoothEquipmentsState {
  final List<BluetoothEquipmentModel> bluetoothEquipments;

  BluetoothEquipmentsBackgroundListLoadedState({
    required this.bluetoothEquipments,
  });
}

final class BluetoothEquipmentsListLoadedState
    extends BluetoothEquipmentsState {
  final List<BluetoothEquipmentModel> bluetoothEquipments;

  BluetoothEquipmentsListLoadedState({
    required this.bluetoothEquipments,
  });
}
