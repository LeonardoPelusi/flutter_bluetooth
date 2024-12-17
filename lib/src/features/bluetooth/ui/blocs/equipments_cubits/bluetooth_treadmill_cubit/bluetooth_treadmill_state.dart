part of 'bluetooth_treadmill_cubit.dart';

abstract class BluetoothTreadmillState extends Equatable {
  const BluetoothTreadmillState();

  @override
  List<Object> get props => [];
}

class BluetoothTreadmillInitial extends BluetoothTreadmillState {}

class BluetoothTreadmillConnecting extends BluetoothTreadmillState {
  final BluetoothEquipmentModel equipment;
  const BluetoothTreadmillConnecting({required this.equipment});
}

class BluetoothTreadmillConnected extends BluetoothTreadmillState {
  final BluetoothEquipmentModel equipment;
  const BluetoothTreadmillConnected({required this.equipment});
}

class BluetoothTreadmillError extends BluetoothTreadmillState {
  final String message;
  const BluetoothTreadmillError({required this.message});
}
