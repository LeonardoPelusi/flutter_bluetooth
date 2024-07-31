import 'dart:async';

import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_connect_ftms_enum.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_helper.dart';

part 'bluetooth_equipments_list_event.dart';
part 'bluetooth_equipments_list_state.dart';

class BluetoothEquipmentsListBloc
    extends Bloc<BluetoothEquipmentsListEvent, BluetoothEquipmentsListState> {
  BluetoothEquipmentsListBloc({
    required this.bluetoothConnectFTMS,
  }
      //!TODO Adicionar bluetooth shared preferences service
      // this._bluetoothSharedPreferencesService,
      ) : super(BluetoothEquipmentsListInitialState()) {
    on<BluetoothEquipmentsListStartScanEvent>(_startScan);
    on<BluetoothEquipmentsListOnDeviceDiscoveredEvent>(_onDeviceDiscovered);

    _flutterReactiveBle.statusStream.listen((event) {
      if (event == BleStatus.ready) {
        // Caso o equipamento seja uma esteira-usb não será necessário
        // realizar esses processos
        // if (!_isTreadmillUSB) {
        // add(BluetoothEquipmentsListStartScanEvent());
        //   add(BluetoothEquipmentsBackgroundScanEvent());
        // }
      } else {
        // !TODO adiocionar tratamento de erro
      }
    });
  }

  final BluetoothConnectFTMS bluetoothConnectFTMS;
  // final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;

  // Services
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();
  final BluetoothEquipmentService _bluetoothEquipmentService =
      BluetoothEquipmentService.instance;

  // Control Variables
  StreamSubscription<DiscoveredDevice>? _subscription;
  Timer? _resetTimer;

  Future<void> _startScan(
    BluetoothEquipmentsListStartScanEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    emit(BluetoothEquipmentsListLoadingState());

    await _setSubscription();
    _resetTimer?.cancel();
    _resetTimer =
        Timer.periodic(event.resetTime, (_) async => await _setSubscription());
  }

  Future<void> _setSubscription() async {
    await _flutterReactiveBle.deinitialize();
    await _flutterReactiveBle.initialize();
    _subscription?.cancel();
    _subscription = _flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      add(BluetoothEquipmentsListOnDeviceDiscoveredEvent(device: device));
    });
  }

  Future<void> _onDeviceDiscovered(
    BluetoothEquipmentsListOnDeviceDiscoveredEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    final DiscoveredDevice device = event.device;

    final BluetoothEquipmentType equipmentType =
        BluetoothHelper.getBluetoothEquipmentType(device);

    if (equipmentType == BluetoothEquipmentType.undefined) return;

    final String newId = _bluetoothEquipmentService.getEquipmentId(
      manufacturerData: device.manufacturerData,
      device: device,
    );

    final BluetoothEquipmentModel newEquipment = BluetoothEquipmentModel(
      id: newId,
      equipment: device,
      equipmentType: equipmentType,
    );

    if (!state.bluetoothEquipments.contains(newEquipment)) {
      emit(BluetoothEquipmentsListAddEquipmentState(
        bluetoothEquipments: [
          ...state.bluetoothEquipments,
          newEquipment,
        ],
      ));
    }
  }

  @override
  Future<void> close() async {
    Bluetooth.heartRateConnected.value =
        HeartRateBleController(deviceConnected: false, open: true);
    Bluetooth.bikeConnected.value = BikeBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.treadmillConnected.value = TreadmillBleController(
        deviceConnected: false, openBox: true, openFooter: true);

    await _subscription?.cancel();
    _resetTimer?.cancel();
    _flutterReactiveBle.deinitialize();
    super.close();
  }

  // !TODO BLUETOOTH: Implementar Automatic Connect

  // Future<void> _automaticConnect(
  //   BluetoothEquipmentsListAutomacticConnectEvent event,
  //   Emitter<BluetoothEquipmentsListState> emit,
  // ) async {
  //   if (bikeList.length == 1 && treadmillList.isEmpty) {
  //     bikeList[0].equipment.connect();
  //   } else if (treadmillList.length == 1 && bikeList.isEmpty) {
  //     treadmillList[0].equipment.connect();
  //   }

  //   if (frequencyMeterList.length == 1) {
  //     frequencyMeterList[0].equipment.connect();
  //   }

  //   if (bikeList.length > 1 ||
  //       treadmillList.length > 1 ||
  //       frequencyMeterList.length > 1) {
  //     emit(BluetoothEquipmentsBackgroundListLoadedState(
  //       bluetoothEquipments: _equipmentList,
  //     ));
  //   }
  // }

  // !TODO BLUETOOTH: Implementar SharedPreferences

  // connect without scanning
// final File file = File('/remoteId.txt');
// var device = BluetoothDevice.fromId(await file.readAsString());
// await device.connect();

  // Future<void> _sharedPreferencesTryConnectWithEquipment(
  //     DeviceWithId device) async {
  //   final String equipmentId = _bluetoothSharedPreferencesService.equipmentId;

  //   if (device.device.id.id == equipmentId) {
  //     await _bluetoothEquipmentBloc.connectDevice(device);
  //   }
  // }
}
