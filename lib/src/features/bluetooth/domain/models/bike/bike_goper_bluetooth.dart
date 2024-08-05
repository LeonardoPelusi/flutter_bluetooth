import 'package:equatable/equatable.dart';

class BikeGoperBluetooth extends Equatable {
  const BikeGoperBluetooth({
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

const initialBikeGoperBluetooth = BikeGoperBluetooth(
  cadence: 0,
  power: 0,
  resistance: 0,
  speed: 0.0,
);
