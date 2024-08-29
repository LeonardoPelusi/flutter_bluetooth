import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part '../../domain/bluetooth_guid.dart';

abstract class BluetoothEquipmentService {
  static final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();

  static String getEquipmentId({
    required DiscoveredDevice device,
  }) {
    late String newId;
    final Uint8List manufacturerData = device.manufacturerData;
    if (device.manufacturerData.isEmpty) {
      newId = '';
    } else {
      if (BluetoothHelper.isBikeKeiser(device)) {
        // abaixo peguei o terceiro byte do manufacture data porque
        // nessa lista não são enviados os bytes 00 e 01 (CompanyId)
        newId = manufacturerData[3].toString();
      } else {
        newId = manufacturerData[2].toString();
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

  static Service _getFitnessMachineService(List<Service> services) {
    return services.firstWhere(
        (service) => service.id == BluetoothGuid.fitnessMachineService);
  }

  static Service _getUserDataService(List<Service> services) {
    return services
        .firstWhere((service) => service.id == BluetoothGuid.userDataService);
  }

  static Service _getFrequencyMeterService(List<Service> services) {
    return services.firstWhere(
      (service) => service.id == BluetoothGuid.frequencyMeterService,
    );
  }

  static Characteristic getBikeIndoorData(List<Service> services) {
    final fitnessMachineService = _getFitnessMachineService(services);
    return fitnessMachineService.characteristics.firstWhere(
      (characteristic) => characteristic.id == BluetoothGuid.bikeIndoorData,
    );
  }

  static Characteristic getTreadmillFitnessData(List<Service> services) {
    final fitnessMachineService = _getFitnessMachineService(services);
    return fitnessMachineService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.id == BluetoothGuid.treadmillFitnessData,
    );
  }

  static Characteristic getUserAge(List<Service> services) {
    final userDataService = _getUserDataService(services);
    return userDataService.characteristics.firstWhere(
      (characteristic) => characteristic.id == BluetoothGuid.userAge,
    );
  }

  static Characteristic getUserWeight(List<Service> services) {
    final userDataService = _getUserDataService(services);
    return userDataService.characteristics.firstWhere(
      (characteristic) => characteristic.id == BluetoothGuid.userWeight,
    );
  }

  static Characteristic getFrequencyMeterData(List<Service> services) {
    final frequencyMeterService = _getFrequencyMeterService(services);
    return frequencyMeterService.characteristics.firstWhere(
      (characteristic) => characteristic.id == BluetoothGuid.userWeight,
    );
  }
}
