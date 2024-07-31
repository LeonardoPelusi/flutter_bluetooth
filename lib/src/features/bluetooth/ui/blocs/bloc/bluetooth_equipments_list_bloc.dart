import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/bluetooth_helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_connect_ftms_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_status_cubit/bluetooth_status_cubit.dart';

part 'bluetooth_equipments_list_event.dart';
part 'bluetooth_equipments_list_state.dart';

class BluetoothEquipmentsListBloc
    extends Bloc<BluetoothEquipmentsListEvent, BluetoothEquipmentsListState> {
  BluetoothEquipmentsListBloc(
    this._bluetoothStatusCubit, {
    required this.bluetoothConnectFTMS,
  }) : super(BluetoothEquipmentsListInitialState()) {
    on<BluetoothEquipmentsListNewScanEvent>(_startScan);
    on<BluetoothEquipmentsListListenScanEvent>(_listenScan);
    on<BluetoothEquipmentsListRemoveConnectedDevicesEvent>(
        _removeConnectedDevices);
    on<BluetoothEquipmentsListDisconnectBluetoothEvent>(_disconnectBluetooth);

    _bluetoothStatusCubit.stream.listen((event) {
      if (event.status == BluetoothStatus.connected) {
        add(BluetoothEquipmentsListNewScanEvent());
      } else if (event.status == BluetoothStatus.disconnected) {
        add(BluetoothEquipmentsListDisconnectBluetoothEvent());
      }
    });
  }

  final BluetoothStatusCubit _bluetoothStatusCubit;
  final BluetoothConnectFTMS bluetoothConnectFTMS;

  // Services
  final BluetoothEquipmentService _bluetoothEquipmentService =
      BluetoothEquipmentService.instance;

  // List
  final List<BluetoothEquipmentModel> _equipmentList =
      <BluetoothEquipmentModel>[];

  Future<void> _startScan(
    BluetoothEquipmentsListNewScanEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    add(BluetoothEquipmentsListListenScanEvent());
    await FlutterBluePlus.startScan(
      withNames: BluetoothHelper.getListOfAvailableEquipments(),
    );
  }

  FutureOr<void> _listenScan(
    BluetoothEquipmentsListListenScanEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
    //  `scanResults` if you want live scan results *or* the results from a previous scan.
    await emit.onEach(
      FlutterBluePlus.onScanResults,
      onData: (List<ScanResult> results) {
        for (ScanResult result in results) {
          final BluetoothDevice newDevice = result.device;

          if (bluetoothConnectFTMS == BluetoothConnectFTMS.bikeAndMybeat &&
              !BluetoothHelper.isBike(newDevice)) {
            return;
          }
          if ((bluetoothConnectFTMS ==
                  BluetoothConnectFTMS.treadmillAndMybeat) &&
              !BluetoothHelper.isTreadmill(newDevice)) {
            return;
          }

          final String newId = _bluetoothEquipmentService.getEquipmentId(
            manufacturerData: result.advertisementData.manufacturerData.values,
            device: newDevice,
          );

          final BluetoothEquipmentType equipmentType =
              BluetoothHelper.getBluetoothEquipmentType(newDevice);

          final BluetoothEquipmentModel newEquipment = BluetoothEquipmentModel(
            id: newId,
            equipment: newDevice,
            equipmentType: equipmentType,
          );

          // if (!_equipmentList.contains(newEquipment)) {
          // _equipmentList.add(newEquipment);
          //!TODO BLUETOOTH: Implementar SharedPreferences
          // if (_bluetoothSharedPreferencesService
          //     .haveTreadmillOnSharedPreferences) {

          // _sharedPreferencesTryConnectWithEquipment(_treadmill);
          // }
          // }

          if (!_equipmentList.contains(newEquipment)) {
            _equipmentList.add(newEquipment);
            emit(BluetoothEquipmentsListAddEquipmentState(
              bluetoothEquipments: [
                ...state.bluetoothEquipments,
                newEquipment,
              ],
            ));
          }
        }
      },
    );
  }

  // Caso haja algum dispositivo ainda conectado (preso), retirar
  Future<void> _removeConnectedDevices(
    BluetoothEquipmentsListRemoveConnectedDevicesEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    for (BluetoothDevice device in FlutterBluePlus.connectedDevices) {
      device.disconnect();
    }
  }

  FutureOr<void> _disconnectBluetooth(
    BluetoothEquipmentsListDisconnectBluetoothEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) {
    add(BluetoothEquipmentsListRemoveConnectedDevicesEvent());
    Bluetooth.heartRateConnected.value =
        HeartRateBleController(deviceConnected: false, open: true);
    Bluetooth.bikeConnected.value = BikeBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.treadmillConnected.value = TreadmillBleController(
        deviceConnected: false, openBox: true, openFooter: true);
  }

  @override
  Future<void> close() {
    FlutterBluePlus.stopScan();
    for (BluetoothDevice device in FlutterBluePlus.connectedDevices) {
      device.disconnect();
    }
    return super.close();
  }
}
