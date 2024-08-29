import 'package:equatable/equatable.dart';

class BikeGoperDirectConnect extends Equatable {
  const BikeGoperDirectConnect({
    required this.cadence,
    required this.power,
    required this.resistance,
    required this.speed,
  });

  final int cadence;
  final int power;
  final int resistance;
  final double speed;

  @override
  List<Object?> get props => [cadence, power, resistance, speed];
}

const initialBikeGoperDirectConnect = BikeGoperDirectConnect(
  cadence: 0,
  power: 0,
  resistance: 0,
  speed: 0.0,
);
