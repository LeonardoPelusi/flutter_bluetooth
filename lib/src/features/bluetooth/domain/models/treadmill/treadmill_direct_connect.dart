import 'package:equatable/equatable.dart';

class TreadmillDirectConnect extends Equatable {
  const TreadmillDirectConnect({
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

const initialTreadmillDirectConnect = TreadmillDirectConnect(
  speed: 0.0,
  inclination: 0.0,
  power: 0,
);
