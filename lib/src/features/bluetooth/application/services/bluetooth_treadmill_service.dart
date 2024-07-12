part of 'bluetooth_equipment_service.dart';

class BluetoothTreadmillService {
  static BluetoothTreadmillService get instance => BluetoothTreadmillService();

  // Equipamento Conectado Atualmente
  BluetoothEquipmentModel? connectedTreadmill;

  //Métricas que serão exibidas
  ValueNotifier<int> instaPower = ValueNotifier<int>(-1);
  ValueNotifier<double> speed = ValueNotifier<double>(0);
  ValueNotifier<double> inclination = ValueNotifier<double>(0);

  // Variáveis para o geração do gráfico
  int powerBest = 0;
  double speedBest = 0;

  // Serviços
  late BluetoothService _fitnessMachineService;
  late BluetoothCharacteristic _treadmillFitnessData;

  // Stream
  StreamSubscription? treadmillCharacteristicStream;

  // Dados
  late List<int> treadmillData;

  //seleciona treadmill para trazer métricas da esteira
  getTreadmillData(List<BluetoothService> _services) async {
    _cleanTreadmillData();

    _fitnessMachineService = _services.firstWhere((service) =>
        service.uuid == BluetoothEquipmentService.guids.fitnessMachineService);

    _treadmillFitnessData = _fitnessMachineService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.uuid ==
          BluetoothEquipmentService.guids.treadmillFitnessData,
    );

    treadmillCharacteristicStream = _treadmillFitnessData.value.listen((value) {
      treadmillData = value;
      int byte = 2;

      if (treadmillData.isNotEmpty) {
        speed.value = ((treadmillData[byte + 1] << 8 | (treadmillData[byte]))
                .toDouble()) /
            100;
        byte += 2;

        if (speed.value > speedBest) speedBest = speed.value;

        if (treadmillData[0] & 0x04 == 0x04) {
          byte += 3;
        }

        inclination.value = (treadmillData[byte].toDouble());

        instaPower.value =
            _powerForTreadmill(speed.value, inclination.value).round();

        if (instaPower.value != 0) {
          if (instaPower.value > powerBest) powerBest = instaPower.value;
        }
      }
    });
    Future.delayed(Duration(milliseconds: 1500));
    await _treadmillFitnessData.setNotifyValue(true);
  }

  void _cleanTreadmillData() {
    connectedTreadmill = null;
    speed.value = 0;
    inclination.value = 0;
    instaPower.value = 0;
    treadmillCharacteristicStream?.cancel();
    treadmillCharacteristicStream = null;
    treadmillData = [];
  }

  // Private methods

  double _powerForTreadmill(double speed, double inclination) {
    double percentage = inclination / 100;

    return speed * 25 * _exponentiationSqr(percentage * 10 + 1);
  }

  double _exponentiationSqr(double number) {
    return number * number;
  }
}
