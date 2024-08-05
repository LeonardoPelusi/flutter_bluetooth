import 'package:equatable/equatable.dart';

class TreadmillBluetooth extends Equatable {
  const TreadmillBluetooth({
    required this.speed,
    required this.inclination,
    required this.power,
  });

  final double speed;
  final double inclination;
  final int power;

  @override
  List<Object?> get props => [speed, inclination, power];
}

const initialTreadmillBluetooth = TreadmillBluetooth(
  speed: 0.0,
  inclination: 0.0,
  power: 0,
);
