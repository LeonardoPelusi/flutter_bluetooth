import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_status_cubit/bluetooth_status_cubit.dart';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/bluetooth_helper.dart';

part 'bluetooth_equipments_event.dart';
part 'bluetooth_equipments_state.dart';

class BluetoothEquipmentsBloc
    extends Bloc<BluetoothEquipmentsEvent, BluetoothEquipmentsState> {
  BluetoothEquipmentsBloc(
    this._bluetoothStatusCubit,
    //!TODO Adicionar bluetooth shared preferences service
    // this._bluetoothSharedPreferencesService,
  ) : super(BluetoothEquipmentsInitialState()) {
    on<BluetoothEquipmentsBackgroundScanEvent>(_backgroundScan);
    on<BluetoothEquipmentsNewScanEvent>(_newScan);
    on<BluetoothEquipmentsListenScanEvent>(_listenScan);
    on<BluetoothEquipmentsAutomacticConnectEvent>(_automaticConnect);
    on<BluetoothEquipmentsRemoveConnectedDevicesEvent>(_removeConnectedDevices);
    on<BluetoothEquipmentsDisconnectBluetoothEvent>(_disconnectBluetooth);

    _bluetoothStatusCubit.stream.listen((event) {
      if (event == BluetoothStatusState.connected) {
        // Caso o equipamento seja uma esteira-usb não será necessário
        // realizar esses processos
        // if (!_isTreadmillUSB) {
        add(BluetoothEquipmentsRemoveConnectedDevicesEvent());
        //   add(BluetoothEquipmentsBackgroundScanEvent());
        // }
      } else if (event == BluetoothStatusState.disconnected) {
        add(BluetoothEquipmentsDisconnectBluetoothEvent(closeTraining: false));
      }
    });
  }

  final BluetoothStatusCubit _bluetoothStatusCubit;
  // final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;

  // Packages
  final FlutterBluePlus _flutterBluePlus = FlutterBluePlus.instance;

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

  // Validators
  // !TODO BLUETOOTH: Implementar variáveis de acordo com o equipamento ou ConnectFTMS
  final bool _isBike = true;
  final bool _isTreadmillBLE = true;
  final bool _isTreadmillUSB = false;
  final bool _isFrequencyMeter = true;

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
    BluetoothEquipmentsBackgroundScanEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) async {
    // await _cancelStream();
    add(BluetoothEquipmentsListenScanEvent(isBackgroundScan: true));
    await _flutterBluePlus
        .startScan(
      timeout: _backgroundScanTimeoutDuration,
      withServices: event.retries >= 3
          ? []
          // : _bluetoothSharedPreferencesService.getServicesValidation(),
          : [],
    )
        .then((_) async {
      // Caso o usuário der stop no scan, não será necessário realizar esses processos
      if (_equipmentList.isNotEmpty) {
        add(BluetoothEquipmentsAutomacticConnectEvent());
      }
      if ((_isBike && bikeList.isEmpty) ||
          (_isTreadmillBLE && treadmillList.isEmpty)) {
        add(BluetoothEquipmentsBackgroundScanEvent(
          retries: event.retries + 1,
        ));
      }
    });
  }

  Future<void> _newScan(
    BluetoothEquipmentsNewScanEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) async {
    _equipmentList.clear();
    add(BluetoothEquipmentsListenScanEvent());
    await _flutterBluePlus
        .startScan(
      timeout: _newScanTimeoutDuration,
      withServices: event.isRetry
          ? []
          // : _bluetoothSharedPreferencesService.getServicesValidation(),
          : [],
    )
        .then((_) {
      // Caso o usuário der stop no scan, não será necessário realizar esses processos
      emit(BluetoothEquipmentsListLoadedState(
        bluetoothEquipments: _equipmentList,
      ));
    });
  }

  Future<void> _listenScan(
    BluetoothEquipmentsListenScanEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) async {
    emit(BluetoothEquipmentsListLoadingState());

    await emit.onEach(
      _flutterBluePlus.scanResults,
      onData: (List<ScanResult> results) {
        for (ScanResult result in results) {
          BluetoothDevice newDevice = result.device;

          final String newId = _bluetoothEquipmentService.getEquipmentId(
            manufacturerData: result.advertisementData.manufacturerData.values,
            device: newDevice,
          );

          // final BluetoothEquipmentModel newEquipment = BluetoothEquipmentModel(
          //   id: newId,
          //   equipment: newDevice,
          //   equipmentType:
          //       (_isBike && BluetoothHelper.bikeValidation(newDevice))
          //           ? BluetoothEquipmentType.bikeGoper
          //           : _isTreadmillBLE &&
          //                   BluetoothHelper.treadmillValidation(newDevice)
          //               ? BluetoothHelper.frequencyMeterValidation(newDevice)
          //                   ? BluetoothEquipmentType.frequencyMeter
          //                   : BluetoothEquipmentType.treadmill
          //               : BluetoothEquipmentType.undefined,
          // );

          // if (!_equipmentList.contains(newEquipment)) {
          //   _equipmentList.add(newEquipment);
          // }

          if (_isBike && BluetoothHelper.bikeValidation(newDevice)) {
            final bool _isBikeKeiser = BluetoothHelper.bikeKeiserValidation(
              newDevice,
            );

            final BluetoothEquipmentModel bike = BluetoothEquipmentModel(
              id: newId,
              equipment: newDevice,
              equipmentType: _isBikeKeiser
                  ? BluetoothEquipmentType.bikeKeiser
                  : BluetoothEquipmentType.bikeGoper,
            );
            if (!_equipmentList.contains(bike)) {
              _equipmentList.add(bike);
              if (event.isBackgroundScan) {
                // !TODO BLUETOOTH: Implementar SharedPreferences
                // if (_bluetoothSharedPreferencesService.bikeOnSharedPreferences) {
                // _sharedPreferencesTryConnectWithEquipment(_bike);
                // }
              } else {
                emit(BluetoothEquipmentsListAddEquipmentState(
                  bluetoothEquipments: [
                    ...state.bluetoothEquipments,
                    bike,
                  ],
                ));
              }
            }
          } else if (_isTreadmillBLE &&
              BluetoothHelper.treadmillValidation(newDevice)) {
            final BluetoothEquipmentModel treadmill = BluetoothEquipmentModel(
              id: newId,
              equipment: newDevice,
              equipmentType: BluetoothEquipmentType.treadmill,
            );
            if (!_equipmentList.contains(treadmill)) {
              _equipmentList.add(treadmill);
              if (event.isBackgroundScan) {
                // !TODO BLUETOOTH: Implementar SharedPreferences
                // if (_bluetoothSharedPreferencesService
                //     .haveTreadmillOnSharedPreferences) {

                // _sharedPreferencesTryConnectWithEquipment(_treadmill);
                // }
              } else {
                emit(BluetoothEquipmentsListAddEquipmentState(
                  bluetoothEquipments: [
                    ...state.bluetoothEquipments,
                    treadmill,
                  ],
                ));
              }
            }
          } else if (BluetoothHelper.frequencyMeterValidation(newDevice)) {
            final BluetoothEquipmentModel frequencyMeter =
                BluetoothEquipmentModel(
              id: newId,
              equipment: newDevice,
              equipmentType: BluetoothEquipmentType.frequencyMeter,
            );
            if (!_equipmentList.contains(frequencyMeter)) {
              _equipmentList.add(frequencyMeter);
              if (!event.isBackgroundScan) {
                emit(BluetoothEquipmentsListAddEquipmentState(
                  bluetoothEquipments: [
                    ...state.bluetoothEquipments,
                    frequencyMeter,
                  ],
                ));
              }
            }
          }
        }
      },
    );
  }

  Future<void> _automaticConnect(
    BluetoothEquipmentsAutomacticConnectEvent event,
    Emitter<BluetoothEquipmentsState> emit,
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
    BluetoothEquipmentsRemoveConnectedDevicesEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) async {
    _flutterBluePlus.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        device.disconnect();
      }
    });
  }

  Future<void> _disconnectBluetooth(
    BluetoothEquipmentsDisconnectBluetoothEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) async {
    _equipmentList.clear();
    _bluetoothEquipmentService.disconnect();
  }

  @override
  Future<void> close() async {
    add(BluetoothEquipmentsDisconnectBluetoothEvent());
    super.close();
  }

  // !TODO BLUETOOTH: Implementar SharedPreferences
  // Future<void> _sharedPreferencesTryConnectWithEquipment(
  //     DeviceWithId device) async {
  //   final String equipmentId = _bluetoothSharedPreferencesService.equipmentId;

  //   if (device.device.id.id == equipmentId) {
  //     await _bluetoothEquipmentBloc.connectDevice(device);
  //   }
  // }

  void disconnectBluetooth({bool closingTraining = true}) {
    Bluetooth.heartRateConnected.value =
        HeartRateBleController(deviceConnected: false, open: true);
    Bluetooth.bikeConnected.value = BikeBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.treadmillConnected.value = TreadmillBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    // _bikeKeiserCubit.cancelBikeKeiserBroadcastDetection();
    // _bikeKeiserCubit.deinitialize();
    // if (closingTraining) {
    //   _bikeKeiserCubit.close();
    // }
  }
}
