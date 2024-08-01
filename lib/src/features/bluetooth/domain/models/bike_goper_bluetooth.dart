import 'package:equatable/equatable.dart';

class BikeGoperBluetooth extends Equatable {
  const BikeGoperBluetooth({
    required this.id,
    required this.cadence,
    required this.power,
    required this.resistance,
    required this.speed,
  });

  final int id;
  final int cadence;
  final int power;
  final int resistance;
  final double speed;

  @override
  List<Object?> get props => [id, cadence, power, resistance, speed];
}

const initialBikeGoperBluetooth = BikeGoperBluetooth(
  id: 0,
  cadence: 0,
  power: 0,
  resistance: 0,
  speed: 0,
);
