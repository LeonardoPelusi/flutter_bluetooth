import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/core/list_bluetooth_equipment_model_extension.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part 'bluetooth_equipments_state.dart';

abstract class BluetoothEquipmentsCubit
    extends Cubit<BluetoothEquipmentsState> {
  BluetoothEquipmentsCubit() : super(const BluetoothEquipmentsState());

  Future<void> startScan({
    Duration resetTime,
  });

  void resetScan();

  Stream<ConnectionStateUpdate> connectToEquipment(
    BluetoothEquipmentModel equipment,
  );

  Stream<BluetoothEquipmentModel> get equipmentsStream;
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

  // Control Variables (Streams)
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  final StreamController<BluetoothEquipmentModel> _broadcastController =
      StreamController<BluetoothEquipmentModel>.broadcast();

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
    _resetTimer = Timer.periodic(
        resetTime, (_) async => await _setSubscription(reset: true));
  }

  Future<void> _setSubscription({bool reset = false}) async {
    if (!reset) {
      await _flutterReactiveBle.deinitialize();
      await _flutterReactiveBle.initialize();
    }
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _scanSubscription = _flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen(_onDeviceDiscovered);
  }

  void _onDeviceDiscovered(DiscoveredDevice device) {
    final BluetoothEquipmentType equipmentType =
        BluetoothHelper.getBluetoothEquipmentType(device);

    if (!_hasValidType(equipmentType)) return;

    final String newId = BluetoothEquipmentService.getEquipmentId(
      manufacturerData: device.manufacturerData,
      device: device,
    );

    final BluetoothConnectionType connectionType =
        BluetoothEquipmentService.getBluetoothConnectionType(
      equipmentType,
    );

    final BluetoothEquipmentModel newEquipment = BluetoothEquipmentModel(
      id: newId,
      equipment: device,
      equipmentType: equipmentType,
      connectionType: connectionType,
    );

    if (!state.bluetoothEquipments.hasEquipment(newEquipment)) {
      emit(state.copyWith(
        bluetoothEquipments: [...state.bluetoothEquipments, newEquipment],
      ));
    } else {
      if (newEquipment.connectionType == BluetoothConnectionType.broadcast) {
        _broadcastController.add(newEquipment);
      }
    }
  }

  bool _hasValidType(BluetoothEquipmentType equipmentType) {
    if (equipmentType == BluetoothEquipmentType.undefined) return false;

    switch (_bluetoothConnectFTMS) {
      case BluetoothConnectFTMS.all:
        break;
      case BluetoothConnectFTMS.bikeAndMybeat:
        if (equipmentType == BluetoothEquipmentType.treadmill) return false;
        break;
      case BluetoothConnectFTMS.treadmillAndMybeat:
        if (equipmentType == BluetoothEquipmentType.bikeGoper ||
            equipmentType == BluetoothEquipmentType.bikeKeiser) return false;
      case BluetoothConnectFTMS.onlyMyBeat:
        if (equipmentType == BluetoothEquipmentType.bikeGoper ||
            equipmentType == BluetoothEquipmentType.bikeKeiser ||
            equipmentType == BluetoothEquipmentType.treadmill) return false;
        break;
    }

    return true;
  }

  // ====================== End Start Scan ======================

  @override
  void resetScan() {
    emit(state.copyWith(
      bluetoothEquipments: [],
    ));
  }

  // ====================== Connect Methods ======================

  @override
  Stream<ConnectionStateUpdate> connectToEquipment(
    BluetoothEquipmentModel equipment,
  ) {
    return _flutterReactiveBle.connectToDevice(
      id: equipment.equipment.id,
      connectionTimeout: _connectionTimeoutDuration,
    );
  }

  // ==================== End Connect Methods ====================

  @override
  Stream<BluetoothEquipmentModel> get equipmentsStream {
    return _broadcastController.stream;
  }

  @override
  Future<void> close() async {
    Bluetooth.heartRateConnected.value =
        HeartRateBleController(deviceConnected: false, open: true);
    Bluetooth.bikeConnected.value = BikeBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.treadmillConnected.value = TreadmillBleController(
        deviceConnected: false, openBox: true, openFooter: true);

    await _flutterReactiveBle.deinitialize();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _broadcastController.close();
    _resetTimer?.cancel();
    _resetTimer = null;
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
