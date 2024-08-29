import 'dart:async';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class BluetoothScanner {
  Future<void> startScan();
  Future<void> stopScan();

  Stream<BluetoothEquipmentModel> get equipmentsStream;
}

class BluetoothScannerImpl implements BluetoothScanner {
  // Packages
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();

  // Control Variables (Enums)
  late final BluetoothConnectFTMS bluetoothConnectFTMS =
      BluetoothConnectFTMS.all;

  // Control Variables (Streams)
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  final StreamController<BluetoothEquipmentModel> _equipmentsController =
      StreamController<BluetoothEquipmentModel>.broadcast();

  // Control Variables (Timers and Durations)
  Timer? _resetTimer;
  final Duration resetTime = const Duration(minutes: 25);

  @override
  Future<void> startScan() async {
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

    if (!BluetoothHelper.hasValidType(
      bluetoothConnectFTMS: BluetoothConnectFTMS.all,
      equipmentType: equipmentType,
    )) return;

    final String newId = BluetoothEquipmentService.getEquipmentId(
      device: device,
    );

    final BluetoothEquipmentModel newEquipment = BluetoothEquipmentModel(
      id: newId,
      equipment: device,
      equipmentType: equipmentType,
      communicationType: equipmentType.getCommunicationType,
    );

    _equipmentsController.add(newEquipment);
  }

  @override
  Stream<BluetoothEquipmentModel> get equipmentsStream =>
      _equipmentsController.stream;

  @override
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _equipmentsController.close();
    _resetTimer?.cancel();
    _flutterReactiveBle.deinitialize();
  }
}
