part of 'bluetooth_equipments_list_bloc.dart';

@immutable
sealed class BluetoothEquipmentsListState extends Equatable {
  final List<BluetoothEquipmentModel> bluetoothEquipments;

  const BluetoothEquipmentsListState({
    this.bluetoothEquipments = const [],
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}

final class BluetoothEquipmentsListInitialState
    extends BluetoothEquipmentsListState {}

final class BluetoothEquipmentsListLoadingState
    extends BluetoothEquipmentsListState {}

final class BluetoothEquipmentsListAddEquipmentState
    extends BluetoothEquipmentsListState {
  const BluetoothEquipmentsListAddEquipmentState({
    required super.bluetoothEquipments,
  });

  @override
  List<Object?> get props => [bluetoothEquipments];
}
