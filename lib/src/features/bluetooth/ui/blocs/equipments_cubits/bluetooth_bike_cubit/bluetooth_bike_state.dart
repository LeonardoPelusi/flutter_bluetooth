part of 'bluetooth_bike_cubit.dart';

class BluetoothBikeState extends Equatable {
  const BluetoothBikeState();

  @override
  List<Object> get props => [];
}

class BluetoothBikeInitial extends BluetoothBikeState {}

class BluetoothBikeConnecting extends BluetoothBikeState {
  final BluetoothEquipmentModel equipment;
  const BluetoothBikeConnecting({required this.equipment});
}

class BluetoothBikeConnected extends BluetoothBikeState {
  final BluetoothEquipmentModel equipment;
  const BluetoothBikeConnected({required this.equipment});
}

class BluetoothBikeError extends BluetoothBikeState {
  final String message;
  const BluetoothBikeError({required this.message});
}
