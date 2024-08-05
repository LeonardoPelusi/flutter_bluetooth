part of '../bluetooth_equipment_service.dart';

class BluetoothBikeService {
  static BluetoothBikeService get instance => BluetoothBikeService();

  final BleBikeMetricsNotifier _bleBikeMetricsNotifier =
      BleBikeMetricsNotifier.instance;

  // Variáveis para a geração de graficos
  // int powerBest = 0;
  // int cadenceMedia = 0;
  // int cadenceBest = 0;
  // int cumulativeCadence = 0;
  // int cadenceLength = 0;

  // Serviços
  late Characteristic _bikeIndoorData;

  // Stream
  StreamSubscription<List<int>>? _bikeCharacteristicStream;

  //seleciona fitness service para capturar os valores de cadencia e potencia
  Future<void> getIndoorBikeData(List<Service> services) async {
    cleanBikeData();

    _bleBikeMetricsNotifier.updateIsConnectedValue(true);

    _bikeIndoorData = BluetoothEquipmentService.getBikeIndoorData(services);

    _bikeCharacteristicStream = _bikeIndoorData.subscribe().listen((value) {
      final BikeGoperBluetooth bikeGoperBluetooth =
          bikeGoperBluetoothSerializer.from(value);

      _bleBikeMetricsNotifier.updateMetrics(
        newCadence: bikeGoperBluetooth.cadence,
        newPower: bikeGoperBluetooth.power,
        newResistance: bikeGoperBluetooth.resistance,
        newSpeed: bikeGoperBluetooth.speed,
      );
    });
    Future.delayed(const Duration(milliseconds: 1500));
    // await _bikeIndoorData.setNotifyValue(true);
  }

  void getBroadcastBikeKeiserData(Uint8List manufacturerData) {
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

  void getBroadcastBikeGoperData(Uint8List manufacturerData) {
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

  void cleanBikeData() {
    _bleBikeMetricsNotifier.clearData();
    _bikeCharacteristicStream?.cancel();
    _bikeCharacteristicStream = null;
  }
}
