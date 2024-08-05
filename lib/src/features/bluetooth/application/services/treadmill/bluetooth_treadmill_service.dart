part of '../bluetooth_equipment_service.dart';

class BluetoothTreadmillService {
  static BluetoothTreadmillService get instance => BluetoothTreadmillService();

  final BleTreadmillMetricsNotifier _bleTreadmillMetricsNotifier =
      BleTreadmillMetricsNotifier.instance;

  // Variáveis para a geração de graficos
  // int powerBest = 0;
  // double speedBest = 0;

  // Serviços
  late Characteristic _treadmillFitnessData;

  // Stream
  StreamSubscription<List<int>>? _treadmillCharacteristicStream;

  //seleciona treadmill para trazer métricas da esteira
  Future<void> getTreadmillData(List<Service> services) async {
    cleanTreadmillData();

    _bleTreadmillMetricsNotifier.updateIsConnectedValue(true);

    _treadmillFitnessData =
        BluetoothEquipmentService.getTreadmillFitnessData(services);

    _treadmillCharacteristicStream =
        _treadmillFitnessData.subscribe().listen((value) {
      final TreadmillBluetooth treadmillBluetooth =
          treadmillBluetoothSerializer.from(value);

      _bleTreadmillMetricsNotifier.updateMetrics(
        newSpeed: treadmillBluetooth.speed,
        newInclination: treadmillBluetooth.inclination,
        newPower: treadmillBluetooth.power,
      );
    });
    Future.delayed(const Duration(milliseconds: 1500));
    // await _treadmillFitnessData.setNotifyValue(true);
  }

  void cleanTreadmillData() {
    _bleTreadmillMetricsNotifier.clearData();
    _treadmillCharacteristicStream?.cancel();
    _treadmillCharacteristicStream = null;
  }
}
