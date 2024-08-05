import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bluetooth/src/features/bluetooth/data/serializers/bluetooth_serializer.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike_goper_bluetooth.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike_goper_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike_keiser_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part 'bluetooth_bike_service.dart';
part 'bluetooth_treadmill_service.dart';
part 'bluetooth_frequence_meter_service.dart';

part '../../../domain/bluetooth_guid.dart';

abstract class BluetoothEquipmentService {
  static bool isBroadcastConnection = false;
  static BluetoothGuid get guids => _BluetoothGuid();

  static final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();

  static String getEquipmentId({
    required Uint8List manufacturerData,
    required DiscoveredDevice device,
  }) {
    late String newId;
    if (manufacturerData.isEmpty) {
      newId = '';
    } else {
      if (BluetoothHelper.isBikeKeiser(device)) {
        // abaixo peguei o terceiro byte do manufacture data porque
        // nessa lista não são enviados os bytes 00 e 01 (CompanyId)
        newId = manufacturerData[3].toString();
      } else {
        newId = manufacturerData.first.toString();
      }
    }
    return newId;
  }

  static Future<List<Service>> getServicesList(
    BluetoothEquipmentModel equipment,
  ) async {
    return await _flutterReactiveBle
        .getDiscoveredServices(equipment.equipment.id);
  }

  static BluetoothConnectionType getBluetoothConnectionType(
      BluetoothEquipmentType equipmentType) {
    switch (equipmentType) {
      case BluetoothEquipmentType.bikeGoper:
        return BluetoothConnectionType.broadcast;
      case BluetoothEquipmentType.bikeKeiser:
        return BluetoothConnectionType.broadcast;
      case BluetoothEquipmentType.treadmill:
        return BluetoothConnectionType.directConnect;
      case BluetoothEquipmentType.frequencyMeter:
        return BluetoothConnectionType.directConnect;
      default:
        return BluetoothConnectionType.na;
    }
  }

  static Service getFitnessMachineService(List<Service> services) {
    return services
        .firstWhere((service) => service.id == guids.fitnessMachineService);
  }
}
