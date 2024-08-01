import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_connect_ftms_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part 'bluetooth_equipments_state.dart';

abstract class BluetoothEquipmentsCubit
    extends Cubit<BluetoothEquipmentsState> {
  BluetoothEquipmentsCubit() : super(const BluetoothEquipmentsState());

  Future<void> startScan({
    Duration resetTime,
  });

  Future<void> connectDevice(
    BluetoothEquipmentModel equipment,
  );

  Future<void> disconnectDevice(
    BluetoothEquipmentModel equipment,
  );
}

class BluetoothEquipmentsCubitImpl extends BluetoothEquipmentsCubit {
  BluetoothEquipmentsCubitImpl(
    this._bluetoothConnectFTMS,
    // this._bluetoothSharedPreferencesService,
  ) : super() {
    _flutterReactiveBle.statusStream.listen((event) {
      if (event == BleStatus.ready) {
        // Caso o equipamento seja uma esteira-usb não será necessário
        // realizar esses processos
        // if (!_isTreadmillUSB) {
        // add(BluetoothEquipmentsStartScanEvent());
        //   add(BluetoothEquipmentsBackgroundScanEvent());
        // }
      } else {
        // !TODO adiocionar tratamento de erro
      }
    });
  }

  final BluetoothConnectFTMS _bluetoothConnectFTMS;
  // final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;

  // Services
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();
  final BluetoothEquipmentService _bluetoothEquipmentService =
      BluetoothEquipmentService.instance;

  // Bluetooth Services
  final BluetoothBikeService _bikeService = BluetoothBikeService.instance;
  // final BluetoothTreadmillService _treadmillService =
  //     BluetoothTreadmillService.instance;
  // final BluetoothFrequencyMeterService _frequencyMeterService =
  //     BluetoothFrequencyMeterService.instance;

  // Control Variables (Streams)
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _bikeStream;
  // StreamController<ConnectionStateUpdate>? _treadmillStream;
  // StreamController<ConnectionStateUpdate>? _frequencyMeterStream;

  // Control Variables (Timers)
  Timer? _resetTimer;
  final Duration _connectionTimeoutDuration = const Duration(seconds: 10);

  // ======================== Scan Methods ========================

  @override
  Future<void> startScan({
    Duration resetTime = const Duration(minutes: 25),
  }) async {
    await _setSubscription();
    _resetTimer?.cancel();
    _resetTimer =
        Timer.periodic(resetTime, (_) async => await _setSubscription());
  }

  Future<void> _setSubscription() async {
    await _flutterReactiveBle.deinitialize();
    await _flutterReactiveBle.initialize();
    _scanSubscription?.cancel();
    _scanSubscription = _flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen(_onDeviceDiscovered);
  }

  void _onDeviceDiscovered(DiscoveredDevice device) {
    final BluetoothEquipmentType equipmentType =
        BluetoothHelper.getBluetoothEquipmentType(device);

    if (equipmentType == BluetoothEquipmentType.undefined) return;

    final String newId = _bluetoothEquipmentService.getEquipmentId(
      manufacturerData: device.manufacturerData,
      device: device,
    );

    bool contains = false;

    for (BluetoothEquipmentModel equipment in state.bluetoothEquipments) {
      if (equipment.id == newId) {
        contains = true;
        return;
      }
      contains = false;
    }

    final BluetoothEquipmentModel newEquipment = BluetoothEquipmentModel(
      id: newId,
      equipment: device,
      equipmentType: equipmentType,
    );

    if (!contains) {
      emit(state.copyWith(
        bluetoothEquipments: [...state.bluetoothEquipments, newEquipment],
      ));
    } else {
      // TODO: Tratar métricas broadcast
      if (state.connectedEquipments.contains(newEquipment)) {}
    }
  }

  // ====================== End Start Scan ======================

  // ====================== Connect Methods ======================

  @override
  Future<void> connectDevice(BluetoothEquipmentModel equipment) async {
    switch (equipment.equipmentType) {
      case BluetoothEquipmentType.bikeGoper:
        _listenToDeviceState(equipment, _bikeStream);
        break;
      case BluetoothEquipmentType.treadmill:
        // _listenToDeviceState(equipment, _treadmillStream);

        break;
      case BluetoothEquipmentType.frequencyMeter:
        // _listenToDeviceState(equipment, _frequencyMeterStream);
        break;
      default:
        break;
    }
  }

  Future<void> _listenToDeviceState(
    BluetoothEquipmentModel equipment,
    StreamSubscription<ConnectionStateUpdate>? connectionStream,
  ) async {
    connectionStream = _flutterReactiveBle
        .connectToDevice(
      id: equipment.equipment.id,
      connectionTimeout: _connectionTimeoutDuration,
    )
        .listen((equipmentState) {
      switch (equipmentState.connectionState) {
        case DeviceConnectionState.connecting:
          break;
        case DeviceConnectionState.connected:
          _listenToDeviceServices(equipment);
          emit(state.copyWith(
            connectedEquipments: [...state.connectedEquipments, equipment],
          ));
          break;
        case DeviceConnectionState.disconnecting:
          break;
        case DeviceConnectionState.disconnected:
          disconnectDevice(equipment);
          break;
        default:
          break;
      }

      if (equipmentState.failure != null) {
        switch (equipmentState.failure?.code) {
          case ConnectionError.failedToConnect:
            break;
          case ConnectionError.unknown:
            break;
          default:
            break;
        }
        disconnectDevice(equipment);
      }
    }, onError: (e) async {
      await connectionStream?.cancel();
      disconnectDevice(equipment);
    });
  }

  Future<void> _listenToDeviceServices(
      BluetoothEquipmentModel equipment) async {
    List<Service> services =
        await _flutterReactiveBle.getDiscoveredServices(equipment.equipment.id);

    switch (equipment.equipmentType) {
      case BluetoothEquipmentType.bikeGoper:
        // _trainingFlowData.postBikeGraph = true;
        // await _bluetoothSharedPreferencesService.bluetoothCryptoBikeGoper(
        //   bikeId: bluetoothEquipment.equipment.id.id,
        // );
        _bikeService.updateConnectedBike(equipment);
        await _bikeService.getIndoorBikeData(services);
        break;
      case BluetoothEquipmentType.treadmill:
        // _trainingFlowData.postTreadmillGraph = true;

        // await _bluetoothSharedPreferencesService
        //     .bluetoothCryptoTreadmillBLE(
        //   treadmillId: bluetoothEquipment.equipment.id.id,
        // );
        // _treadmillService.updateConnectedTreadmill(equipment);
        // await _treadmillService.getTreadmillData(services);
        break;
      case BluetoothEquipmentType.frequencyMeter:
        // _trainingFlowData.postBpmGraph = true;

        // int userAge = _trainingFlowData.userAge!;
        // double userWeight = _trainingFlowData.userWeight!;
        // await _bleFrequencyMeterService.getUserData(
        //   services,
        //   userAge,
        //   userWeight,
        // );

        // _frequencyMeterService
        //     .updateConnectedFrequencyMeter(equipment);
        // await _frequencyMeterService.getFrequencyMeterMeasurement(services);
        break;
      default:
        break;
    }
  }

  @override
  Future<void> disconnectDevice(BluetoothEquipmentModel equipment) async {
    switch (equipment.equipmentType) {
      case BluetoothEquipmentType.bikeKeiser ||
            BluetoothEquipmentType.bikeGoper:
        _bikeService.cleanBikeData();
        _bikeStream?.cancel();
        _bikeStream = null;
        break;
      case BluetoothEquipmentType.treadmill:
        // _treadmillService.cleanTreadmillData();
        break;
      case BluetoothEquipmentType.frequencyMeter:
        // _frequencyMeterService.clearUserData();
        // _frequencyMeterService.cleanFequencyMeterData();
        break;
      default:
        break;
    }

    emit(state.copyWith(
      connectedEquipments: state.connectedEquipments
          .where((element) => element.id != equipment.id)
          .toList(),
    ));
  }

  // ==================== End Connect Methods ====================

  @override
  Future<void> close() async {
    Bluetooth.heartRateConnected.value =
        HeartRateBleController(deviceConnected: false, open: true);
    Bluetooth.bikeConnected.value = BikeBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.treadmillConnected.value = TreadmillBleController(
        deviceConnected: false, openBox: true, openFooter: true);

    await _scanSubscription?.cancel();
    _resetTimer?.cancel();
    _flutterReactiveBle.deinitialize();
    super.close();
  }

  // !TODO BLUETOOTH: Implementar Automatic Connect

  // Future<void> _automaticConnect(
  //   BluetoothEquipmentsAutomacticConnectEvent event,
  //   Emitter<BluetoothEquipmentsState> emit,
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
