part of '../bluetooth_serializer.dart';

final treadmillBluetoothSerializer = TreadmillBluetoothSerializer();

class TreadmillBluetoothSerializer
    implements BluetoothSerializer<TreadmillBluetooth, Uint8List> {
  @override
  TreadmillBluetooth from(List<int> treadmillData) {
    if (treadmillData.isEmpty) return initialTreadmillBluetooth;

    int byte = 2;

    late double speed;
    late double inclination;
    late int power;

    speed =
        ((treadmillData[byte + 1] << 8 | (treadmillData[byte])).toDouble()) /
            100;
    byte += 2;

    if (treadmillData[0] & 0x04 == 0x04) {
      byte += 3;
    }

    inclination = (treadmillData[byte].toDouble());

    power = _powerForTreadmill(speed, inclination).round();

    final result = TreadmillBluetooth(
      speed: speed,
      inclination: inclination,
      power: power,
    );
    return result;
  }

  @override
  to(TreadmillBluetooth object) {
    throw UnimplementedError();
  }

  double _powerForTreadmill(double speed, double inclination) {
    double percentage = inclination / 100;

    return speed * 25 * _exponentiationSqr(percentage * 10 + 1);
  }

  double _exponentiationSqr(double number) {
    return number * number;
  }
}
