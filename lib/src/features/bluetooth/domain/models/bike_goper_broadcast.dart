import 'package:equatable/equatable.dart';

class BikeGoperBroadcast extends Equatable {
  const BikeGoperBroadcast({
    required this.cadence,
    required this.power,
    required this.resistance,
  });

  final int cadence;
  final int power;
  final int resistance;

  @override
  List<Object?> get props => [cadence, power, resistance];
}

const initialBikeGoperBroadcast = BikeGoperBroadcast(
  cadence: 0,
  power: 0,
  resistance: 0,
);
