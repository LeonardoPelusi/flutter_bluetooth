import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/extensions/list_bluetooth_equipment_model_extension.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/data/infrastructure/bluetooth_scanner.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part 'bluetooth_equipments_state.dart';

abstract class BluetoothEquipmentsCubit
    extends Cubit<BluetoothEquipmentsState> {
  BluetoothEquipmentsCubit() : super(const BluetoothEquipmentsState());

  void startScan();

  void resetScan();

  Stream<ConnectionStateUpdate> connectToEquipment(
    BluetoothEquipmentModel equipment,
  );

  Stream<BluetoothEquipmentModel> get equipmentsStream;
}

class BluetoothEquipmentsCubitImpl extends BluetoothEquipmentsCubit {
  BluetoothEquipmentsCubitImpl(
      // this._bluetoothSharedPreferencesService,
      );

  final BluetoothScanner _bluetoothScanner = BluetoothScannerImpl();

  // final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;

  // Services
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();

  // Control Variables (Streams)
  final StreamController<BluetoothEquipmentModel> _broadcastController =
      StreamController<BluetoothEquipmentModel>.broadcast();

  // Control Variables (Timers)
  final Duration _connectionTimeoutDuration = const Duration(seconds: 10);

  // ======================== Scan Methods ========================

  @override
  void startScan() {
    _bluetoothScanner.startScan();
    _listenToEquipmentsStream();
  }

  void _listenToEquipmentsStream() {
    _bluetoothScanner.equipmentsStream.listen(_onEquipmentDiscovered);
  }

  void _onEquipmentDiscovered(BluetoothEquipmentModel equipment) {
    if (!state.bluetoothEquipments.hasEquipment(equipment)) {
      emit(state.copyWith(
        bluetoothEquipments: [...state.bluetoothEquipments, equipment],
      ));
    } else {
      if (equipment.communicationType == BluetoothCommunicationType.all ||
          equipment.communicationType == BluetoothCommunicationType.broadcast) {
        _broadcastController.add(equipment);
      }
    }
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

    _bluetoothScanner.stopScan();
    await _broadcastController.close();
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
