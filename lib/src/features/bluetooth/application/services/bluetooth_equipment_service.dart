import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'bluetooth_treadmill_service.dart';

part '../bluetooth_guid.dart';

class BluetoothEquipmentService {
  static final BluetoothEquipmentService instance = BluetoothEquipmentService();

  BluetoothGuid get guids => _BluetoothGuid();
  TreadmillService get treadmillService => TreadmillService.instance;

  ValueNotifier<List<bool>> get connectedDevices => ValueNotifier([
        false,
        false,
        treadmillService.connectedTreadmill != null,
      ]);

  String getEquipmentId({
    required Iterable<List<int>> manufacturerData,
    required BluetoothDevice device,
  }) {
    late String newId;
    if (manufacturerData.isEmpty) {
      newId = '';
    } else {
      if (device.name.contains('M3')) {
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
