part of 'bluetooth_bike_cubit.dart';

sealed class BluetoothBikeState extends Equatable {
  const BluetoothBikeState();

  @override
  List<Object> get props => [];
}

final class BluetoothBikeInitial extends BluetoothBikeState {}

final class BluetoothBikeConnecting extends BluetoothBikeState {
  final BluetoothEquipmentModel equipment;
  const BluetoothBikeConnecting({required this.equipment});
}

final class BluetoothBikeConnected extends BluetoothBikeState {
  final BluetoothEquipmentModel equipment;
  const BluetoothBikeConnected({required this.equipment});
}

final class BluetoothBikeError extends BluetoothBikeState {
  final String message;
  const BluetoothBikeError({required this.message});
}
