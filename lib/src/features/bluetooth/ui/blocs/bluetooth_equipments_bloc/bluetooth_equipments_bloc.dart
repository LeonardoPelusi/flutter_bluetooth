import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/extension.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_shared_preferences_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipment_bloc/bluetooth_equipment_bloc.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_status_cubit/bluetooth_status_cubit.dart';
import 'package:meta/meta.dart';

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

  // Bluetooth Services
  final BluetoothBikeService _bleBikeService =
      BluetoothEquipmentService.instance.bikeService;
  final BluetoothTreadmillService _bleTreadmillService =
      BluetoothEquipmentService.instance.treadmillService;
  final BluetoothFrequencyMeterService _bleFrequencyMeterService =
      BluetoothEquipmentService.instance.frequencyMeterService;

  // Scan Timeout Durations
  final Duration _backgroundScanTimeoutDuration = const Duration(seconds: 10);
  // final Duration _newScanTimeoutDuration = const Duration(seconds: 30);
  final Duration _newScanTimeoutDuration = const Duration(seconds: 5);

  // List
  final List<BluetoothEquipmentModel> _equipmentList =
      <BluetoothEquipmentModel>[];
  final List<BluetoothEquipmentModel> _bikeList = <BluetoothEquipmentModel>[];
  final List<BluetoothEquipmentModel> _treadmillList =
      <BluetoothEquipmentModel>[];
  final List<BluetoothEquipmentModel> _frequencyMeterList =
      <BluetoothEquipmentModel>[];

  // Validators
  // !TODO BLUETOOTH: Implementar variáveis de acordo com o equipamento ou ConnectFTMS
  final bool _isBike = true;
  final bool _isTreadmillBLE = true;
  final bool _isTreadmillUSB = false;
  final bool _isFrequencyMeter = true;

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
      _populateList();
      if (_equipmentList.isNotEmpty) {
        add(BluetoothEquipmentsAutomacticConnectEvent());
      }
      if ((_isBike && _bikeList.isEmpty) ||
          (_isTreadmillBLE && _treadmillList.isEmpty)) {
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
    _clearList();
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
      _populateList();
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
        print('onData');
        for (ScanResult result in results) {
          BluetoothDevice newDevice = result.device;

          final String newId = _bluetoothEquipmentService.getEquipmentId(
            manufacturerData: result.advertisementData.manufacturerData.values,
            device: newDevice,
          );

          if (_isBike && BluetoothHelper.bikeValidation(newDevice)) {
            final BluetoothEquipmentModel bike = BluetoothEquipmentModel(
              id: newId,
              equipment: newDevice,
              equipmentType: BluetoothEquipmentType.bikeGoper,
            );
            if (!_bikeList.contains(bike)) {
              _bikeList.add(bike);
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
            if (!_treadmillList.contains(treadmill)) {
              _treadmillList.add(treadmill);
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
            if (!_frequencyMeterList.contains(frequencyMeter)) {
              _frequencyMeterList.add(frequencyMeter);
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

    // _scanStream =
    //     _flutterBluePlus.scanResults.listen((List<ScanResult> results) {
    //   print('flutter: bluetooth scan results: ${results.length}');
    //   for (ScanResult result in results) {
    //     final BluetoothDevice newDevice = result.device;
    //     final Iterable<List<int>> manufacturerData =
    //         result.advertisementData.manufacturerData.values;

    //     final String newId = _bluetoothEquipmentService.getEquipmentId(
    //       manufacturerData: manufacturerData,
    //       device: newDevice,
    //     );

    //     if (_isBike && BluetoothHelper.bikeValidation(newDevice)) {
    //       final bool _isBikeKeiser = BluetoothHelper.bikeKeiserValidation(
    //         newDevice,
    //       );

    //       final BluetoothEquipmentModel bike = BluetoothEquipmentModel(
    //         id: newId,
    //         equipment: newDevice,
    //         equipmentType: _isBikeKeiser
    //             ? BluetoothEquipmentType.bikeKeiser
    //             : BluetoothEquipmentType.bikeGoper,
    //       );
    //       if (!_bikeList.contains(bike)) {
    //         _bikeList.add(bike);
    //       }
    //       if (event.isBackgroundScan) {
    //         // !TODO BLUETOOTH: Implementar SharedPreferences
    //         // if (_bluetoothSharedPreferencesService.bikeOnSharedPreferences) {
    //         // _sharedPreferencesTryConnectWithEquipment(_bike);
    //         // }
    //       } else {
    //         // emit(BluetoothEquipmentsListAddEquipmentState(
    //         //   bluetoothEquipment: bike,
    //         // ));
    //       }
    //     } else if (_isTreadmillBLE &&
    //         BluetoothHelper.treadmillValidation(newDevice)) {
    //       final BluetoothEquipmentModel treadmill = BluetoothEquipmentModel(
    //         id: newId,
    //         equipment: newDevice,
    //         equipmentType: BluetoothEquipmentType.treadmill,
    //       );
    //       if (!_treadmillList.contains(treadmill)) {
    //         _treadmillList.add(treadmill);
    //       }
    //       if (event.isBackgroundScan) {
    //         // !TODO BLUETOOTH: Implementar SharedPreferences
    //         // if (_bluetoothSharedPreferencesService
    //         //     .haveTreadmillOnSharedPreferences) {

    //         // _sharedPreferencesTryConnectWithEquipment(_treadmill);
    //         // }
    //       } else {
    //         // emit(BluetoothEquipmentsListAddEquipmentState(
    //         //   bluetoothEquipment: treadmill,
    //         // ));
    //       }
    //     } else if (BluetoothHelper.frequencyMeterValidation(newDevice)) {
    //       final BluetoothEquipmentModel frequencyMeter =
    //           BluetoothEquipmentModel(
    //         id: newId,
    //         equipment: newDevice,
    //         equipmentType: BluetoothEquipmentType.frequencyMeter,
    //       );
    //       if (!_frequencyMeterList.contains(frequencyMeter)) {
    //         _frequencyMeterList.add(frequencyMeter);
    //       }
    //       if (!event.isBackgroundScan) {
    //         // emit(BluetoothEquipmentsListAddEquipmentState(
    //         //   bluetoothEquipment: frequencyMeter,
    //         // ));
    //       }
    //     }
    //   }
    // });
  }

  Future<void> _automaticConnect(
    BluetoothEquipmentsAutomacticConnectEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) async {
    if (_bikeList.length == 1 && _treadmillList.isEmpty) {
      _bikeList[0].equipment.connect();
    } else if (_treadmillList.length == 1 && _bikeList.isEmpty) {
      _treadmillList[0].equipment.connect();
    }

    if (_frequencyMeterList.length == 1) {
      _frequencyMeterList[0].equipment.connect();
    }

    if (_bikeList.length > 1 ||
        _treadmillList.length > 1 ||
        _frequencyMeterList.length > 1) {
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
    _bikeList.clear();
    _treadmillList.clear();
    _frequencyMeterList.clear();
    _bleBikeService.connectedBike?.equipment.disconnect();
    _bleBikeService.disconnectBike();
    _bleTreadmillService.connectedTreadmill?.equipment.disconnect();
    _bleTreadmillService.disconnectTreadmill();
    _bleFrequencyMeterService.connectedFrequencyMeter?.equipment.disconnect();
    _bleFrequencyMeterService.disconnectFrequencyMeter();
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

  // Tratamento das Listas

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

  void _populateList() {
    _equipmentList.clear();

    _equipmentList.addAll([
      ..._bikeList,
      ..._treadmillList,
      ..._frequencyMeterList,
    ]);
  }

  void _clearList() {
    _bikeList.clear();
    _treadmillList.clear();
    _frequencyMeterList.clear();
  }
}
