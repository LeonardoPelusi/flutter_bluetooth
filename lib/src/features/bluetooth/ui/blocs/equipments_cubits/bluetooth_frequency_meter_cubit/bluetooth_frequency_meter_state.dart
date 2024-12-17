part of 'bluetooth_frequency_meter_cubit.dart';

sealed class BluetoothFrequencyMeterState extends Equatable {
  const BluetoothFrequencyMeterState();

  @override
  List<Object> get props => [];
}

final class BluetoothFrequencyMeterInitial extends BluetoothFrequencyMeterState {}

final class BluetoothFrequencyMeterConnecting extends BluetoothFrequencyMeterState {
  final BluetoothEquipmentModel equipment;
  const BluetoothFrequencyMeterConnecting({required this.equipment});
}

final class BluetoothFrequencyMeterConnected extends BluetoothFrequencyMeterState {
  final BluetoothEquipmentModel equipment;
  const BluetoothFrequencyMeterConnected({required this.equipment});
}

final class BluetoothFrequencyMeterError extends BluetoothFrequencyMeterState {
  final String message;
  const BluetoothFrequencyMeterError({required this.message});
}
