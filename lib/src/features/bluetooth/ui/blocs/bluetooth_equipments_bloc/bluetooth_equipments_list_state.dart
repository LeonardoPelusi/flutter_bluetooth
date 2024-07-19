part of 'bluetooth_equipments_list_bloc.dart';

@immutable
sealed class BluetoothEquipmentsListState extends Equatable {
  final List<BluetoothEquipmentModel> bluetoothEquipments;

  const BluetoothEquipmentsListState({
    this.bluetoothEquipments = const [],
  });
}

final class BluetoothEquipmentsListInitialState extends BluetoothEquipmentsListState {
  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsListLoadingState
    extends BluetoothEquipmentsListState {
  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsListAddEquipmentState
    extends BluetoothEquipmentsListState {
  const BluetoothEquipmentsListAddEquipmentState({
    required super.bluetoothEquipments,
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsBackgroundListLoadedState
    extends BluetoothEquipmentsListState {
  const BluetoothEquipmentsBackgroundListLoadedState({
    required super.bluetoothEquipments,
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsListLoadedState
    extends BluetoothEquipmentsListState {
  const BluetoothEquipmentsListLoadedState({
    required super.bluetoothEquipments,
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}
