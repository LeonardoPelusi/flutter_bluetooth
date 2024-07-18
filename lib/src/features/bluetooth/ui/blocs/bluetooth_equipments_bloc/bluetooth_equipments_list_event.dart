part of 'bluetooth_equipments_list_bloc.dart';

@immutable
sealed class BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListBackgroundScanEvent
    extends BluetoothEquipmentsListEvent {
  final int retries;
  BluetoothEquipmentsListBackgroundScanEvent({this.retries = 0});
}

class BluetoothEquipmentsListBackgroundListenScanEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListNewScanEvent extends BluetoothEquipmentsListEvent {
  final bool isRetry;

  BluetoothEquipmentsListNewScanEvent({this.isRetry = false});
}

class BluetoothEquipmentsListAddNewEquipmentEvent
    extends BluetoothEquipmentsListEvent {
  final BluetoothEquipmentModel newEquipment;
  BluetoothEquipmentsListAddNewEquipmentEvent({required this.newEquipment});
}

class BluetoothEquipmentsListNewScanListenScanEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListAutomacticConnectEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListRemoveConnectedDevicesEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListDisconnectBluetoothEvent
    extends BluetoothEquipmentsListEvent {
  final bool closeTraining;

  BluetoothEquipmentsListDisconnectBluetoothEvent({this.closeTraining = true});
}
