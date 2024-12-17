part of 'bluetooth_frequency_meter_cubit.dart';

class BluetoothFrequencyMeterState extends Equatable {
  const BluetoothFrequencyMeterState();

  @override
  List<Object> get props => [];
}

class BluetoothFrequencyMeterInitial extends BluetoothFrequencyMeterState {}

class BluetoothFrequencyMeterConnecting extends BluetoothFrequencyMeterState {
  final BluetoothEquipmentModel equipment;
  const BluetoothFrequencyMeterConnecting({required this.equipment});
}

class BluetoothFrequencyMeterConnected extends BluetoothFrequencyMeterState {
  final BluetoothEquipmentModel equipment;
  const BluetoothFrequencyMeterConnected({required this.equipment});
}

class BluetoothFrequencyMeterError extends BluetoothFrequencyMeterState {
  final String message;
  const BluetoothFrequencyMeterError({required this.message});
}
