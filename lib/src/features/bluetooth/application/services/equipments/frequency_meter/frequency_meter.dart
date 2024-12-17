import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bluetooth_broadcast_equipment.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bluetooth_direct_connect_equipment.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/data/serializers/bluetooth_serializer.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/frequency_meter/frequency_meter_direct_connect.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class FrequencyMeter
    implements BluetoothBroadcastEquipment, BluetoothDirectConnectEquipment {
  // Notifiers
  final BleFrequencyMeterMetricsNotifier _bleFrequencyMeterMetricsNotifier =
      BleFrequencyMeterMetricsNotifier.instance;

  // Stream
  StreamSubscription<List<int>>? _frequencyMeterCharacteristicStream;

  @override
  Future<void> getDataFromManufacturerData(Uint8List manufacturerData) async {}

  //seleciona o servico de user data para escrever os campos idade e peso
  Future<void> getUserData(
    List<Service> services,
    int idade,
    double peso,
  ) async {
    final Characteristic userAge =
        BluetoothEquipmentService.getUserAge(services);
    final Characteristic userWeight =
        BluetoothEquipmentService.getUserWeight(services);

    int pesoDecimal = int.tryParse(peso.toString().split('.')[1])!;

    await userAge.write([idade]);
    await userWeight.write([peso.truncate(), pesoDecimal]);

    // List<int> age = await userAge.read();
    // List<int> weight = await userWeight.read();
  }

  @override
  Future<void> getDataFromServices(List<Service> services) async {
    await cleanData();

    _bleFrequencyMeterMetricsNotifier.updateIsConnectedValue(true);

    final Characteristic frequencyMeterData =
        BluetoothEquipmentService.getFrequencyMeterData(services);

    _frequencyMeterCharacteristicStream =
        frequencyMeterData.subscribe().listen((value) {
      final FrequencyMeterDirectConnect frequencyMeterDirectConnect =
          frequencyMeterDirectConnectSerializer.from(value);

      _bleFrequencyMeterMetricsNotifier.updateMetrics(
        newBpm: frequencyMeterDirectConnect.bpm,
      );
    });
  }

  @override
  Future<void> cleanData() async {
    _bleFrequencyMeterMetricsNotifier.clearData();
    await _frequencyMeterCharacteristicStream?.cancel();
    _frequencyMeterCharacteristicStream = null;
  }
}
