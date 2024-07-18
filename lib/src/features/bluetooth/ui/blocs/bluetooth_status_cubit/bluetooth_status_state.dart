part of 'bluetooth_status_cubit.dart';

enum BluetoothStatus {
  initial,
  connected,
  disconnected,
  error,
  unavailable,
}

final class BluetoothStatusState {
  const BluetoothStatusState({this.status = BluetoothStatus.initial});
  final BluetoothStatus status;
}
