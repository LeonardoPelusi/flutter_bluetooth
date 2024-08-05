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

  // Stream
  StreamSubscription<List<int>>? _bikeCharacteristicStream;

  //seleciona fitness service para capturar os valores de cadencia e potencia
  Future<void> getIndoorBikeData(List<Service> services) async {
    cleanBikeData();

    _bleBikeMetricsNotifier.updateIsConnectedValue(true);

    final Characteristic bikeIndoorData =
        BluetoothEquipmentService.getBikeIndoorData(services);

    _bikeCharacteristicStream = bikeIndoorData.subscribe().listen((value) {
      final BikeGoperBluetooth bikeGoperBluetooth =
          bikeGoperBluetoothSerializer.from(value);

      _bleBikeMetricsNotifier.updateMetrics(
        newCadence: bikeGoperBluetooth.cadence,
        newPower: bikeGoperBluetooth.power,
        newResistance: bikeGoperBluetooth.resistance,
        newSpeed: bikeGoperBluetooth.speed,
      );
    });
  }

  void getBroadcastBikeKeiserData(Uint8List manufacturerData) {
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

  void getBroadcastBikeGoperData(Uint8List manufacturerData) {
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

  void cleanBikeData() {
    _bleBikeMetricsNotifier.clearData();
    _bikeCharacteristicStream?.cancel();
    _bikeCharacteristicStream = null;
  }
}
