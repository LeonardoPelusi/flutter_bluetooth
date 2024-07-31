part of 'bluetooth_equipments_list_bloc.dart';

@immutable
sealed class BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListStartScanEvent
    extends BluetoothEquipmentsListEvent {
  final Duration resetTime;

  BluetoothEquipmentsListStartScanEvent({
    this.resetTime = const Duration(minutes: 25),
  });
}

class BluetoothEquipmentsListOnDeviceDiscoveredEvent
    extends BluetoothEquipmentsListEvent {
  final DiscoveredDevice device;
  BluetoothEquipmentsListOnDeviceDiscoveredEvent({required this.device});
}
