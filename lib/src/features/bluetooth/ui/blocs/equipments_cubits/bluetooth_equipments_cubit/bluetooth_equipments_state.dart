part of 'bluetooth_equipments_cubit.dart';

class BluetoothEquipmentsState extends Equatable {
  final List<BluetoothEquipmentModel> bluetoothEquipments;

  const BluetoothEquipmentsState({
    this.bluetoothEquipments = const [],
  });

  @override
  List<Object> get props => [
        bluetoothEquipments,
      ];

  BluetoothEquipmentsState copyWith({
    List<BluetoothEquipmentModel>? bluetoothEquipments,
  }) {
    return BluetoothEquipmentsState(
      bluetoothEquipments: bluetoothEquipments ?? this.bluetoothEquipments,
    );
  }
}
