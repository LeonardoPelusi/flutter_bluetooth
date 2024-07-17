part of 'bluetooth_equipments_list_bloc.dart';

@immutable
sealed class BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListBackgroundScanEvent
    extends BluetoothEquipmentsListEvent {
  final int retries;
  BluetoothEquipmentsListBackgroundScanEvent({this.retries = 0});
}

class BluetoothEquipmentsListNewScanEvent extends BluetoothEquipmentsListEvent {
  final bool isRetry;

  BluetoothEquipmentsListNewScanEvent({this.isRetry = false});
}

class BluetoothEquipmentsListListenScanEvent
    extends BluetoothEquipmentsListEvent {
  final bool isBackgroundScan;

  BluetoothEquipmentsListListenScanEvent({this.isBackgroundScan = false});
}

class BluetoothEquipmentsListAutomacticConnectEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListRemoveConnectedDevicesEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListDisconnectBluetoothEvent
    extends BluetoothEquipmentsListEvent {
  final bool closeTraining;

  BluetoothEquipmentsListDisconnectBluetoothEvent({this.closeTraining = true});
}
