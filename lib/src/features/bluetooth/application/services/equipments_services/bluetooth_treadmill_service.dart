part of 'bluetooth_equipment_service.dart';

class BluetoothTreadmillService {
  static BluetoothTreadmillService get instance => BluetoothTreadmillService();

  final BleTreadmillMetricsNotifier _bleTreadmillMetricsNotifier =
      BleTreadmillMetricsNotifier.instance;

  // Variáveis para a geração de graficos
  int powerBest = 0;
  double speedBest = 0;

  // Serviços
  // late BluetoothService _fitnessMachineService;
  // late BluetoothCharacteristic _treadmillFitnessData;

  // Stream
  StreamSubscription? treadmillCharacteristicStream;

  // Dados
  late List<int> treadmillData;

  // Equipamento Conectado Atualmente
  BluetoothEquipmentModel? _connectedTreadmill;
  BluetoothEquipmentModel? get connectedTreadmill => _connectedTreadmill;

  void updateConnectedTreadmill(BluetoothEquipmentModel treadmill) {
    _connectedTreadmill = treadmill;
    _bleTreadmillMetricsNotifier.updateIsConnectedValue(true);
  }

  //seleciona treadmill para trazer métricas da esteira
  // Future<void> getTreadmillData(List<BluetoothService> _services) async {
  //   _resetVariables();

  //   _fitnessMachineService = _services.firstWhere((service) =>
  //       service.uuid == BluetoothEquipmentService.guids.fitnessMachineService);

  //   _treadmillFitnessData = _fitnessMachineService.characteristics.firstWhere(
  //     (characteristic) =>
  //         characteristic.uuid ==
  //         BluetoothEquipmentService.guids.treadmillFitnessData,
  //   );

  //   treadmillCharacteristicStream =
  //       _treadmillFitnessData.lastValueStream.listen((value) {
  //     treadmillData = value;
  //     int byte = 2;

  //     if (treadmillData.isNotEmpty) {
  //       late double speed;
  //       late double inclination;
  //       late int instaPower;

  //       speed = ((treadmillData[byte + 1] << 8 | (treadmillData[byte]))
  //               .toDouble()) /
  //           100;
  //       byte += 2;

  //       if (speed > speedBest) speedBest = speed;

  //       if (treadmillData[0] & 0x04 == 0x04) {
  //         byte += 3;
  //       }

  //       inclination = (treadmillData[byte].toDouble());

  //       instaPower = _powerForTreadmill(speed, inclination).round();

  //       if (instaPower != 0) {
  //         if (instaPower > powerBest) powerBest = instaPower;
  //       }

  //       _bleTreadmillMetricsNotifier.updateMetrics(
  //         newInstaPower: instaPower,
  //         newSpeed: speed,
  //         newInclination: inclination,
  //       );
  //     }
  //   });
  //   Future.delayed(const Duration(milliseconds: 1500));
  //   await _treadmillFitnessData.setNotifyValue(true);
  // }

  void _resetVariables() {
    _bleTreadmillMetricsNotifier.clearMetrics();
    treadmillCharacteristicStream?.cancel();
    treadmillCharacteristicStream = null;
    treadmillData = [];
  }

  void cleanTreadmillData() {
    _connectedTreadmill = null;
    _bleTreadmillMetricsNotifier.updateIsConnectedValue(false);
    _resetVariables();
  }

  double _powerForTreadmill(double speed, double inclination) {
    double percentage = inclination / 100;

    return speed * 25 * _exponentiationSqr(percentage * 10 + 1);
  }

  double _exponentiationSqr(double number) {
    return number * number;
  }
}
