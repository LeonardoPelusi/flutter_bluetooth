import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bluetooth_broadcast_equipment.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bluetooth_direct_connect_equipment.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/data/serializers/bluetooth_serializer.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_goper_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_goper_direct_connect.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BikeGoper
    implements BluetoothBroadcastEquipment, BluetoothDirectConnectEquipment {
  // Notifiers
  final BleBikeMetricsNotifier _bleBikeMetricsNotifier =
      BleBikeMetricsNotifier.instance;

  // Stream
  StreamSubscription<List<int>>? _bikeCharacteristicStream;

  @override
  Future<void> getDataFromManufacturerData(Uint8List manufacturerData) async {
    _bleBikeMetricsNotifier.updateIsConnectedValue(true);

    final BikeGoperBroadcast bikeGoperBroadcast =
        bikeGoperBroadcastSerializer.from(manufacturerData);

    _bleBikeMetricsNotifier.updateMetrics(
      newCadence: bikeGoperBroadcast.cadence,
      newPower: bikeGoperBroadcast.power,
      newResistance: bikeGoperBroadcast.resistance,
      // newSpeed: bikeGoperBroadcast.speed,
      newSpeed: 0,
    );
  }

  @override
  Future<void> getDataFromServices(List<Service> services) async {
    await cleanData();

    _bleBikeMetricsNotifier.updateIsConnectedValue(true);

    final Characteristic bikeIndoorData =
        BluetoothEquipmentService.getBikeIndoorData(services);

    _bikeCharacteristicStream = bikeIndoorData.subscribe().listen((value) {
      final BikeGoperDirectConnect bikeGoperDirectConnect =
          bikeGoperDirectConnectSerializer.from(value);

      _bleBikeMetricsNotifier.updateMetrics(
        newCadence: bikeGoperDirectConnect.cadence,
        newPower: bikeGoperDirectConnect.power,
        newResistance: bikeGoperDirectConnect.resistance,
        newSpeed: bikeGoperDirectConnect.speed,
      );
    });
  }

  @override
  Future<void> cleanData() async {
    _bleBikeMetricsNotifier.clearData();
    await _bikeCharacteristicStream?.cancel();
    _bikeCharacteristicStream = null;
  }
}
