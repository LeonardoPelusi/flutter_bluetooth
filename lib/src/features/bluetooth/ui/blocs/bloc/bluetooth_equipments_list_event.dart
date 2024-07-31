part of 'bluetooth_equipments_list_bloc.dart';

sealed class BluetoothEquipmentsListEvent extends Equatable {
  const BluetoothEquipmentsListEvent();

  @override
  List<Object> get props => [];
}

class BluetoothEquipmentsListNewScanEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListListenScanEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListRemoveConnectedDevicesEvent
    extends BluetoothEquipmentsListEvent {}

class BluetoothEquipmentsListDisconnectBluetoothEvent
    extends BluetoothEquipmentsListEvent {}
