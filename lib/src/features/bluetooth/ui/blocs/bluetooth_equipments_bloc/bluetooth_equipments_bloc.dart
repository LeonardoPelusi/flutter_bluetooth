import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_shared_preferences_service.dart';
import 'package:meta/meta.dart';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/bluetooth_helper.dart';

part 'bluetooth_equipments_event.dart';
part 'bluetooth_equipments_state.dart';

class BluetoothEquipmentsBloc
    extends Bloc<BluetoothEquipmentsEvent, BluetoothEquipmentsState> {
  BluetoothEquipmentsBloc(
    this._bluetoothSharedPreferencesService,
  ) : super(BluetoothEquipmentsInitialState()) {
    on<BluetoothEquipmentsBackgroundScanEvent>(_backgroundScan);
    on<BluetoothEquipmentsNewScanEvent>(_newScan);
    on<BluetoothEquipmentsListenScanEvent>(_listenScan);
    on<BluetoothEquipmentsAutomacticConnectEvent>(_automaticConnect);
    on<BluetoothEquipmentsRemoveConnectedDevicesEvent>(_removeConnectedDevices);
    on<BluetoothEquipmentsDisconnectBluetoothEvent>(_disconnectBluetooth);

    _flutterBluePlus.state.listen((event) {
      if (event == BluetoothState.on || event == BluetoothState.turningOn) {
        Bluetooth.bleOn.value = true;
        // Caso o equipamento seja uma esteira-usb não será necessário
        // realizar esses processos
        if (!_isTreadmillUSB) {
          add(BluetoothEquipmentsRemoveConnectedDevicesEvent());
          add(BluetoothEquipmentsBackgroundScanEvent());
        }
      } else if (event == BluetoothState.turningOff ||
          event == BluetoothState.off) {
        Bluetooth.bleOn.value = false;
        add(BluetoothEquipmentsDisconnectBluetoothEvent(closeTraining: false));
        Bluetooth.connectedDevices.value = [false, false, false];
      }
    });
  }

  // Packages
  final FlutterBluePlus _flutterBluePlus = FlutterBluePlus.instance;

  // Services
  final BluetoothEquipmentService _bluetoothEquipmentService =
      BluetoothEquipmentService.instance;
  final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;

  // Stream
  StreamSubscription<List<ScanResult>>? _scanStream;

  // Scan Timeout Durations
  final Duration _backgroundScanTimeoutDuration = const Duration(seconds: 10);
  final Duration _newScanTimeoutDuration = const Duration(seconds: 30);

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
  final bool _isBike = false;
  final bool _isTreadmillBLE = false;
  final bool _isTreadmillUSB = false;
  final bool _isFrequencyMeter = false;

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
          : _bluetoothSharedPreferencesService.getServicesValidation(),
    )
        .then((_) async {
      // Caso o usuário der stop no scan, não será necessário realizar esses processos
      if (_scanStream != null) {
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
      }

      _cancelStream();
    });
  }

  Future<void> _newScan(
    BluetoothEquipmentsNewScanEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) async {
    _cancelStream();
    _clearList();
    add(BluetoothEquipmentsListenScanEvent());
    await _flutterBluePlus
        .startScan(
      timeout: _newScanTimeoutDuration,
      withServices: event.isRetry
          ? []
          : _bluetoothSharedPreferencesService.getServicesValidation(),
    )
        .then((_) async {
      // Caso o usuário der stop no scan, não será necessário realizar esses processos
      if (_scanStream != null) {
        _populateList();
        emit(BluetoothEquipmentsListLoadedState(
          bluetoothEquipments: _equipmentList,
        ));
      }
    });
  }

  void _listenScan(
    BluetoothEquipmentsListenScanEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) {
    emit(BluetoothEquipmentsListLoadingState());
    _scanStream =
        _flutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        BluetoothDevice newDevice = result.device;

        final String newId = _bluetoothEquipmentService.getEquipmentId(
          manufacturerData: result.advertisementData.manufacturerData.values,
          device: newDevice,
        );

        if (_isBike && BluetoothHelper.bikeValidation(newDevice)) {
          _addEquipmentInList(
            equipmentType: BluetoothEquipmentType.bikeGoper,
            equipment: newDevice,
            id: newId,
          );
          if (event.isBackgroundScan) {
            // !TODO BLUETOOTH: Implementar SharedPreferences
            // if (_bluetoothSharedPreferencesService.bikeOnSharedPreferences) {
            // _sharedPreferencesTryConnectWithEquipment(_bike);
            // }
          } else {
            emit(BluetoothEquipmentsListAddEquipmentState(bluetoothEquipment: _bike));
          }
        } else if (_isTreadmillBLE &&
            BluetoothHelper.treadmillValidation(newDevice)) {
          _addEquipmentInList(
            equipmentType: BluetoothEquipmentType.treadmill,
            equipment: newDevice,
            id: newId,
          );
          if (event.isBackgroundScan) {
            // !TODO BLUETOOTH: Implementar SharedPreferences
            // if (_bluetoothSharedPreferencesService
            //     .haveTreadmillOnSharedPreferences) {

            // _sharedPreferencesTryConnectWithEquipment(_treadmill);
            // }
          } else {
            emit(BluetoothEquipmentsListAddEquipmentState(bluetoothEquipment: _treadmill));
          }
        } else if (BluetoothHelper.frequencyMeterValidation(newDevice)) {
          _addEquipmentInList(
            equipmentType: BluetoothEquipmentType.frequence_meter,
            equipment: newDevice,
            id: newId,
          );
          if (!event.isBackgroundScan) {
            emit(BluetoothEquipmentsListAddEquipmentState(bluetoothEquipment: _frequencyMeter));
          }
        }
      }
    });
  }

  void _automaticConnect(
    BluetoothEquipmentsAutomacticConnectEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) {
    if (_bikeList.length == 1 && _treadmillList.isEmpty) {
      _bluetoothEquipmentCubit.connectDevice(_bikeList[0]);
    } else if (_treadmillList.length == 1 && _bikeList.isEmpty) {
      _bluetoothEquipmentCubit.connectDevice(_treadmillList[0]);
    }

    if (_frequencyMeterList.length == 1) {
      _bluetoothEquipmentCubit.connectDevice(_frequencyMeterList[0]);
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
  void _removeConnectedDevices(
    BluetoothEquipmentsRemoveConnectedDevicesEvent event,
    Emitter<BluetoothEquipmentsState> emit,
  ) {
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
    _cancelStream();
    _equipmentList.clear();
    _bikeList.clear();
    _treadmillList.clear();
    _frequencyMeterList.clear();
    Bluetooth.bleOn.value = false;
    _bluetoothEquipmentCubit.disconnectBluetooth(
      closingTraining: event.closeTraining,
    );
  }

  @override
  Future<void> close() async {
    add(BluetoothEquipmentsDisconnectBluetoothEvent());
    super.close();
  }

  void _addEquipmentInList({
    required BluetoothEquipmentType equipmentType,
    required BluetoothDevice equipment,
    required String id,
  }) {
    switch (equipmentType) {
      case BluetoothEquipmentType.bikeGoper:
        final BluetoothEquipmentModel _bike = BluetoothEquipmentModel(
          id: id,
          equipment: equipment,
          equipmentType: BluetoothEquipmentType.bikeGoper,
        );
        if (!_bikeList.contains(_bike)) {
          _bikeList.add(_bike);
        }
        break;
      case BluetoothEquipmentType.treadmill:
        final BluetoothEquipmentModel _treadmill = BluetoothEquipmentModel(
          id: id,
          equipment: equipment,
          equipmentType: BluetoothEquipmentType.treadmill,
        );
        if (!_treadmillList.contains(_treadmill)) {
          _treadmillList.add(_treadmill);
        }
        break;
      case BluetoothEquipmentType.frequence_meter:
        final BluetoothEquipmentModel _frequencyMeter = BluetoothEquipmentModel(
          id: id,
          equipment: equipment,
          equipmentType: BluetoothEquipmentType.frequence_meter,
        );
        if (!_frequencyMeterList.contains(_frequencyMeter)) {
          _frequencyMeterList.add(_frequencyMeter);
        }
        break;
      default:
        break;
    }
  }



  // !TODO BLUETOOTH: Implementar SharedPreferences
  // Future<void> _sharedPreferencesTryConnectWithEquipment(
  //     DeviceWithId device) async {
  //   final String equipmentId = _bluetoothSharedPreferencesService.equipmentId;

  //   if (device.device.id.id == equipmentId) {
  //     await _bluetoothEquipmentCubit.connectDevice(device);
  //   }
  // }

  // Tratamento das Listas

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

  // Tratamento das Streams

  void _cancelStream() {
    _scanStream?.cancel();
    _scanStream = null;
  }
}
