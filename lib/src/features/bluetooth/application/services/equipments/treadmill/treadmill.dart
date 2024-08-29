import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bluetooth_broadcast_equipment.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bluetooth_direct_connect_equipment.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/data/serializers/bluetooth_serializer.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/treadmill/treadmill_direct_connect.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class Treadmill
    implements BluetoothBroadcastEquipment, BluetoothDirectConnectEquipment {
  // Notifiers
  final BleTreadmillMetricsNotifier _bleTreadmillMetricsNotifier =
      BleTreadmillMetricsNotifier.instance;

  // Stream
  StreamSubscription<List<int>>? _treadmillCharacteristicStream;

  @override
  Future<void> getDataFromManufacturerData(Uint8List manufacturerData) async {}

  @override
  Future<void> getDataFromServices(List<Service> services) async {
    await cleanData();

    _bleTreadmillMetricsNotifier.updateIsConnectedValue(true);

    final Characteristic treadmillFitnessData =
        BluetoothEquipmentService.getTreadmillFitnessData(services);

    _treadmillCharacteristicStream =
        treadmillFitnessData.subscribe().listen((value) {
      final TreadmillDirectConnect treadmillDirectConnect =
          treadmillDirectConnectSerializer.from(value);

      _bleTreadmillMetricsNotifier.updateMetrics(
        newSpeed: treadmillDirectConnect.speed,
        newInclination: treadmillDirectConnect.inclination,
        newPower: treadmillDirectConnect.power,
      );
    });
  }

  @override
  Future<void> cleanData() async {
    _bleTreadmillMetricsNotifier.clearData();
    await _treadmillCharacteristicStream?.cancel();
    _treadmillCharacteristicStream = null;
  }
}
