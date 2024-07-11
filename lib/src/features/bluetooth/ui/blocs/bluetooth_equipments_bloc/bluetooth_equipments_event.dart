part of 'bluetooth_equipments_bloc.dart';

@immutable
sealed class BluetoothEquipmentsEvent {}

class BluetoothEquipmentsBackgroundScanEvent extends BluetoothEquipmentsEvent {
  final int retries;
  BluetoothEquipmentsBackgroundScanEvent({this.retries = 0});
}

class BluetoothEquipmentsNewScanEvent extends BluetoothEquipmentsEvent {
  final bool isRetry;

  BluetoothEquipmentsNewScanEvent({this.isRetry = false});
}

class BluetoothEquipmentsListenScanEvent extends BluetoothEquipmentsEvent {
  final bool isBackgroundScan;

  BluetoothEquipmentsListenScanEvent({this.isBackgroundScan = false});
}

class BluetoothEquipmentsAutomacticConnectEvent
    extends BluetoothEquipmentsEvent {}

class BluetoothEquipmentsRemoveConnectedDevicesEvent
    extends BluetoothEquipmentsEvent {}

class BluetoothEquipmentsDisconnectBluetoothEvent
    extends BluetoothEquipmentsEvent {
  final bool closeTraining;

  BluetoothEquipmentsDisconnectBluetoothEvent({this.closeTraining = true});
}
