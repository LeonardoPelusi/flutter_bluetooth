part of '../bluetooth_equipment_service.dart';

class BluetoothFrequencyMeterService {
  static BluetoothFrequencyMeterService get instance =>
      BluetoothFrequencyMeterService();

  final BleFrequencyMeterMetricsNotifier _bleFrequencyMeterMetricsNotifier =
      BleFrequencyMeterMetricsNotifier.instance;

  // int bpmMedia = 0;
  // int bpmBest = 0;
  // int cumulativeBpm = 0;

  // Stream
  StreamSubscription<List<int>>? _frequencyMeterCharacteristicStream;

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

  //seleciona servico do frequency meter para imprimir o frequency meter measurement (BPM)
  Future<void> getFrequencyMeterMeasurement(
    List<Service> services,
  ) async {
    cleanFequencyMeterData();

    _bleFrequencyMeterMetricsNotifier.updateIsConnectedValue(true);

    final Characteristic frequencyMeterData =
        BluetoothEquipmentService.getFrequencyMeterData(services);

    _frequencyMeterCharacteristicStream =
        frequencyMeterData.subscribe().listen((value) {
      final FrequencyMeterBluetooth frequencyMeterBluetooth =
          frequencyMeterBluetoothSerializer.from(value);

      _bleFrequencyMeterMetricsNotifier.updateMetrics(
        newBpm: frequencyMeterBluetooth.bpm,
      );
    });
  }

  void cleanFequencyMeterData() {
    _bleFrequencyMeterMetricsNotifier.clearData();
    _frequencyMeterCharacteristicStream?.cancel();
    _frequencyMeterCharacteristicStream = null;
  }
}
