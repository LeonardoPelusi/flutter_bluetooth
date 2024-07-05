part of 'bluetooth_services.dart';

abstract class TreadmillService {
  late BluetoothService _fitnessMachineService;
  late BluetoothCharacteristic _treadmillFitnessData;
  StreamSubscription? treadmillCharacteristicStream;
  late List<int> treadmillData;

  //seleciona treadmill para trazer métricas da esteira
  getTreadmillData(List<BluetoothService> _services) async {
    _fitnessMachineService = _services.firstWhere((service) =>
        service.uuid == BluetoothServices.guids.fitnessMachineService);

    _treadmillFitnessData = _fitnessMachineService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid ==
            BluetoothServices.guids.treadmillFitnessData);

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
            powerForTreadmill(speed.value, inclination.value).round();

        if (instaPower.value != 0) {
          if (instaPower.value > powerBest) powerBest = instaPower.value;
        }
      }
    });
    Future.delayed(Duration(milliseconds: 1500));
    await _treadmillFitnessData.setNotifyValue(true);
  }

  double powerForTreadmill(double speed, double inclination) {
    double percentage = inclination / 100;

    return speed * 25 * _exponentiationSqr(percentage * 10 + 1);
  }

  double _exponentiationSqr(double number) {
    return number * number;
  }
}
