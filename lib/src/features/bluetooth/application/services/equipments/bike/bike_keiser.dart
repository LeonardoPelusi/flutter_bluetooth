import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bluetooth_broadcast_equipment.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/data/serializers/bluetooth_serializer.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_keiser_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';

class BikeKeiser implements BluetoothBroadcastEquipment {
  // Notifiers
  final BleBikeMetricsNotifier _bleBikeMetricsNotifier =
      BleBikeMetricsNotifier.instance;

  // Stream

  @override
  Future<void> getDataFromManufacturerData(Uint8List manufacturerData) async {
    _bleBikeMetricsNotifier.updateIsConnectedValue(true);

    final BikeKeiserBroadcast bikeKeiserBroadcast =
        bikeKeiserBroadcastSerializer.from(manufacturerData);

    _bleBikeMetricsNotifier.updateMetrics(
      newCadence: bikeKeiserBroadcast.cadence,
      newPower: bikeKeiserBroadcast.power,
      newResistance: bikeKeiserBroadcast.gear,
      // newSpeed: bikeKeiserBroadcast.speed,
      newSpeed: 0,
    );
  }

  @override
  Future<void> cleanData() async {
    _bleBikeMetricsNotifier.clearData();
  }
}
