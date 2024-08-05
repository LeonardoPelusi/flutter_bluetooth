part of 'bluetooth_treadmill_cubit.dart';

sealed class BluetoothTreadmillState extends Equatable {
  const BluetoothTreadmillState();

  @override
  List<Object> get props => [];
}

final class BluetoothTreadmillInitial extends BluetoothTreadmillState {}

final class BluetoothTreadmillConnecting extends BluetoothTreadmillState {
  final BluetoothEquipmentModel equipment;
  const BluetoothTreadmillConnecting({required this.equipment});
}

final class BluetoothTreadmillConnected extends BluetoothTreadmillState {
  final BluetoothEquipmentModel equipment;
  const BluetoothTreadmillConnected({required this.equipment});
}

final class BluetoothTreadmillError extends BluetoothTreadmillState {
  final String message;
  const BluetoothTreadmillError({required this.message});
}
