import 'dart:async';

import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_connect_ftms_enum.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_status_cubit/bluetooth_status_cubit.dart';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/bluetooth_helper.dart';

part 'bluetooth_equipments_list_event.dart';
part 'bluetooth_equipments_list_state.dart';

class BluetoothEquipmentsListBloc
    extends Bloc<BluetoothEquipmentsListEvent, BluetoothEquipmentsListState> {
  BluetoothEquipmentsListBloc(
    this._bluetoothStatusCubit, {
    required this.bluetoothConnectFTMS,
  }
      //!TODO Adicionar bluetooth shared preferences service
      // this._bluetoothSharedPreferencesService,
      ) : super(BluetoothEquipmentsListInitialState()) {
    on<BluetoothEquipmentsListBackgroundScanEvent>(_backgroundScan);
    on<BluetoothEquipmentsListBackgroundListenScanEvent>(_listenBackgroundScan);
    on<BluetoothEquipmentsListNewScanEvent>(_newScan);
    on<BluetoothEquipmentsListNewScanListenScanEvent>(_listenNewScan);
    on<BluetoothEquipmentsListAddNewEquipmentEvent>(_addNewEquipment);
    on<BluetoothEquipmentsListAutomacticConnectEvent>(_automaticConnect);
    on<BluetoothEquipmentsListRemoveConnectedDevicesEvent>(
        _removeConnectedDevices);
    on<BluetoothEquipmentsListDisconnectBluetoothEvent>(_disconnectBluetooth);

    _bluetoothStatusCubit.stream.listen((event) {
      if (event.status == BluetoothStatus.connected) {
        // Caso o equipamento seja uma esteira-usb não será necessário
        // realizar esses processos
        // if (!_isTreadmillUSB) {
        add(BluetoothEquipmentsListRemoveConnectedDevicesEvent());
        //   add(BluetoothEquipmentsBackgroundScanEvent());
        // }
      } else if (event.status == BluetoothStatus.disconnected) {
        add(BluetoothEquipmentsListDisconnectBluetoothEvent(
            closeTraining: false));
      }
    });
  }

  final BluetoothStatusCubit _bluetoothStatusCubit;
  final BluetoothConnectFTMS bluetoothConnectFTMS;
  // final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;

  // Services
  final BluetoothEquipmentService _bluetoothEquipmentService =
      BluetoothEquipmentService.instance;

  // Scan Timeout Durations
  final Duration _backgroundScanTimeoutDuration = const Duration(seconds: 10);
  // final Duration _newScanTimeoutDuration = const Duration(seconds: 30);
  final Duration _newScanTimeoutDuration = const Duration(seconds: 5);

  // List
  final List<BluetoothEquipmentModel> _equipmentList =
      <BluetoothEquipmentModel>[];

  List<BluetoothEquipmentModel> get bikeList => _equipmentList
      .where(
        (equip) =>
            equip.equipmentType == BluetoothEquipmentType.bikeGoper ||
            equip.equipmentType == BluetoothEquipmentType.bikeKeiser,
      )
      .toList();
  List<BluetoothEquipmentModel> get treadmillList => _equipmentList
      .where(
        (equip) => equip.equipmentType == BluetoothEquipmentType.treadmill,
      )
      .toList();
  List<BluetoothEquipmentModel> get frequencyMeterList => _equipmentList
      .where(
        (equip) => equip.equipmentType == BluetoothEquipmentType.frequencyMeter,
      )
      .toList();

  Future<void> _backgroundScan(
    BluetoothEquipmentsListBackgroundScanEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    emit(BluetoothEquipmentsListLoadingState());
    add(BluetoothEquipmentsListBackgroundListenScanEvent());
    await FlutterBluePlus.startScan(
      timeout: _backgroundScanTimeoutDuration,
      withNames: BluetoothHelper.getListOfAvailableEquipments(),
      // withServices: event.retries >= 3
      //     ? []
      //     // : _bluetoothSharedPreferencesService.getServicesValidation(),
      //     : [],
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning
        .where((val) => val == false)
        .first
        .then((_) {
      if (_equipmentList.isNotEmpty) {
        add(BluetoothEquipmentsListAutomacticConnectEvent());
      }
      if ((bluetoothConnectFTMS == BluetoothConnectFTMS.bikeAndMybeat &&
              bikeList.isEmpty) ||
          (bluetoothConnectFTMS == BluetoothConnectFTMS.treadmillAndMybeat &&
              treadmillList.isEmpty)) {
        add(BluetoothEquipmentsListBackgroundScanEvent(
          retries: event.retries + 1,
        ));
      }
    });
  }

  Future<void> _listenBackgroundScan(
    BluetoothEquipmentsListBackgroundListenScanEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    _equipmentList.clear();
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

          if (!_equipmentList.contains(newEquipment)) {
            _equipmentList.add(newEquipment);
            // !TODO BLUETOOTH: Implementar SharedPreferences
            // if (_bluetoothSharedPreferencesService
            //     .haveTreadmillOnSharedPreferences) {

            // _sharedPreferencesTryConnectWithEquipment(_treadmill);
            // }
          }
        }
      },
    );
  }

  Future<void> _newScan(
    BluetoothEquipmentsListNewScanEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    emit(BluetoothEquipmentsListLoadingState());
    add(BluetoothEquipmentsListNewScanListenScanEvent());
    await FlutterBluePlus.startScan(
      timeout: _newScanTimeoutDuration,
      withNames: BluetoothHelper.getListOfAvailableEquipments(),
      // withServices: event.isRetry
      //     ? []
      //     // : _bluetoothSharedPreferencesService.getServicesValidation(),
      //     : [],
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first.then(
          (_) => emit(
            BluetoothEquipmentsListLoadedState(
              bluetoothEquipments: _equipmentList,
            ),
          ),
        );
  }

  Future<void> _listenNewScan(
    BluetoothEquipmentsListNewScanListenScanEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    _equipmentList.clear();
    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning. Use
    //  `scanResults` if you want live scan results *or* the results from a previous scan.

    var subscription = FlutterBluePlus.onScanResults.listen((scanResults) {
      for (ScanResult result in scanResults) {
        final BluetoothDevice newDevice = result.device;

        if (bluetoothConnectFTMS == BluetoothConnectFTMS.bikeAndMybeat &&
            !BluetoothHelper.isBike(newDevice)) {
          return;
        }
        if ((bluetoothConnectFTMS == BluetoothConnectFTMS.treadmillAndMybeat) &&
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

        if (!_equipmentList.contains(newEquipment)) {
          _equipmentList.add(newEquipment);
          add(BluetoothEquipmentsListAddNewEquipmentEvent(
            newEquipment: newEquipment,
          ));
        }
      }
    });

    FlutterBluePlus.cancelWhenScanComplete(subscription);
  }

  Future<void> _addNewEquipment(
    BluetoothEquipmentsListAddNewEquipmentEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    emit(BluetoothEquipmentsListAddEquipmentState(
      bluetoothEquipments: [
        ...state.bluetoothEquipments,
        event.newEquipment,
      ],
    ));
  }

  Future<void> _automaticConnect(
    BluetoothEquipmentsListAutomacticConnectEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    if (bikeList.length == 1 && treadmillList.isEmpty) {
      bikeList[0].equipment.connect();
    } else if (treadmillList.length == 1 && bikeList.isEmpty) {
      treadmillList[0].equipment.connect();
    }

    if (frequencyMeterList.length == 1) {
      frequencyMeterList[0].equipment.connect();
    }

    if (bikeList.length > 1 ||
        treadmillList.length > 1 ||
        frequencyMeterList.length > 1) {
      emit(BluetoothEquipmentsBackgroundListLoadedState(
        bluetoothEquipments: _equipmentList,
      ));
    }
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

  Future<void> _disconnectBluetooth(
    BluetoothEquipmentsListDisconnectBluetoothEvent event,
    Emitter<BluetoothEquipmentsListState> emit,
  ) async {
    _equipmentList.clear();
    add(BluetoothEquipmentsListRemoveConnectedDevicesEvent());
    Bluetooth.heartRateConnected.value =
        HeartRateBleController(deviceConnected: false, open: true);
    Bluetooth.bikeConnected.value = BikeBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.treadmillConnected.value = TreadmillBleController(
        deviceConnected: false, openBox: true, openFooter: true);
  }

  @override
  Future<void> close() async {
    add(BluetoothEquipmentsListDisconnectBluetoothEvent());
    super.close();
  }

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
