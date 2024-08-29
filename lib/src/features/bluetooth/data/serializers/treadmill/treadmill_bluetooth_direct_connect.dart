part of '../bluetooth_serializer.dart';

final treadmillDirectConnectSerializer = TreadmillDirectConnectSerializer();

class TreadmillDirectConnectSerializer
    implements BluetoothSerializer<TreadmillDirectConnect, Uint8List> {
  @override
  TreadmillDirectConnect from(List<int> treadmillData) {
    if (treadmillData.isEmpty) return initialTreadmillDirectConnect;

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

    final result = TreadmillDirectConnect(
      speed: speed,
      inclination: inclination,
      power: power,
    );
    return result;
  }

  @override
  to(TreadmillDirectConnect object) {
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
