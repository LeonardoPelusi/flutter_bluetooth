import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bluetooth/src/features/bluetooth/data/serializers/bluetooth_serializer.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_goper_bluetooth.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_goper_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_keiser_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/frequency_meter/frequency_meter_bluetooth.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/treadmill/treadmill_bluetooth.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part 'bike/bluetooth_bike_service.dart';
part 'treadmill/bluetooth_treadmill_service.dart';
part 'frequency_meter/bluetooth_frequency_meter_service.dart';

part '../../domain/bluetooth_guid.dart';

abstract class BluetoothEquipmentService {
  static bool isBroadcastConnection = false;

  static final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();
  static BluetoothGuid get guids => _BluetoothGuid();

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
        return isBroadcastConnection
            ? BluetoothConnectionType.broadcast
            : BluetoothConnectionType.directConnect;
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

  static Service _getFitnessMachineService(List<Service> services) {
    return services
        .firstWhere((service) => service.id == guids.fitnessMachineService);
  }

  static Service _getUserDataService(List<Service> services) {
    return services
        .firstWhere((service) => service.id == guids.userDataService);
  }

  static Service _getFrequencyMeterService(List<Service> services) {
    return services.firstWhere(
      (service) =>
          service.id == BluetoothEquipmentService.guids.frequencyMeterService,
    );
  }

  static Characteristic getBikeIndoorData(List<Service> services) {
    final fitnessMachineService = _getFitnessMachineService(services);
    return fitnessMachineService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.id == BluetoothEquipmentService.guids.bikeIndoorData,
    );
  }

  static Characteristic getTreadmillFitnessData(List<Service> services) {
    final fitnessMachineService = _getFitnessMachineService(services);
    return fitnessMachineService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.id ==
          BluetoothEquipmentService.guids.treadmillFitnessData,
    );
  }

  static Characteristic getUserAge(List<Service> services) {
    final userDataService = _getUserDataService(services);
    return userDataService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.id == BluetoothEquipmentService.guids.userAge,
    );
  }

  static Characteristic getUserWeight(List<Service> services) {
    final userDataService = _getUserDataService(services);
    return userDataService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.id == BluetoothEquipmentService.guids.userWeight,
    );
  }

  static Characteristic getFrequencyMeterData(List<Service> services) {
    final frequencyMeterService = _getFrequencyMeterService(services);
    return frequencyMeterService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.id == BluetoothEquipmentService.guids.userWeight,
    );
  }
}
