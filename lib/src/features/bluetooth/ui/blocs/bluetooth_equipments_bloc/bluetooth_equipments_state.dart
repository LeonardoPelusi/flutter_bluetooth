part of 'bluetooth_equipments_bloc.dart';

@immutable
sealed class BluetoothEquipmentsState extends Equatable {
  final List<BluetoothEquipmentModel> bluetoothEquipments;

  const BluetoothEquipmentsState({
    this.bluetoothEquipments = const [],
  });
}

final class BluetoothEquipmentsInitialState extends BluetoothEquipmentsState {
  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsListLoadingState
    extends BluetoothEquipmentsState {
  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsListAddEquipmentState
    extends BluetoothEquipmentsState {
  const BluetoothEquipmentsListAddEquipmentState({
    required super.bluetoothEquipments,
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsBackgroundListLoadedState
    extends BluetoothEquipmentsState {
  const BluetoothEquipmentsBackgroundListLoadedState({
    required super.bluetoothEquipments,
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsListLoadedState
    extends BluetoothEquipmentsState {
  const BluetoothEquipmentsListLoadedState({
    required super.bluetoothEquipments,
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}
