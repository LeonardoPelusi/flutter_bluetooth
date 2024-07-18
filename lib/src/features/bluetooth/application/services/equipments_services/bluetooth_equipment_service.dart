import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/data/serializers/bluetooth_serializer.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike_goper_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike_keiser_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';

part 'bluetooth_bike_service.dart';
part 'bluetooth_treadmill_service.dart';
part 'bluetooth_frequence_meter_service.dart';

part '../../bluetooth_guid.dart';

class BluetoothEquipmentService {
  static final BluetoothEquipmentService instance = BluetoothEquipmentService();

  static BluetoothGuid get guids => _BluetoothGuid();

  // Equipments Services
  BluetoothBikeService get bikeService => BluetoothBikeService._instance;
  BluetoothTreadmillService get treadmillService =>
      BluetoothTreadmillService._instance;
  BluetoothFrequencyMeterService get frequencyMeterService =>
      BluetoothFrequencyMeterService._instance;

  String getEquipmentId({
    required Iterable<List<int>> manufacturerData,
    required BluetoothDevice device,
  }) {
    late String newId;
    if (manufacturerData.isEmpty) {
      newId = '';
    } else {
      if (device.platformName.contains('M3')) {
        // abaixo peguei o terceiro byte do manufacture data porque
        // nessa lista não são enviados os bytes 00 e 01 (CompanyId)
        newId = manufacturerData.first[3].toString();
      } else {
        newId = manufacturerData.first.first.toString();
      }
    }
    return newId;
  }
}
