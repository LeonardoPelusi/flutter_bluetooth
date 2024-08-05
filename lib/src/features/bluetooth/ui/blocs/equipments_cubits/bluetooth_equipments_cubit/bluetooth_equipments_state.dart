part of 'bluetooth_equipments_cubit.dart';

class BluetoothEquipmentsState extends Equatable {
  final List<BluetoothEquipmentModel> bluetoothEquipments;
  final List<BluetoothEquipmentModel> connectedEquipments;

  const BluetoothEquipmentsState({
    this.bluetoothEquipments = const [],
    this.connectedEquipments = const [],
  });

  @override
  List<Object> get props => [
        bluetoothEquipments,
        connectedEquipments,
      ];

  BluetoothEquipmentsState copyWith({
    List<BluetoothEquipmentModel>? bluetoothEquipments,
    List<BluetoothEquipmentModel>? connectedEquipments,
  }) {
    return BluetoothEquipmentsState(
      bluetoothEquipments: bluetoothEquipments ?? this.bluetoothEquipments,
      connectedEquipments: connectedEquipments ?? this.connectedEquipments,
    );
  }
}
