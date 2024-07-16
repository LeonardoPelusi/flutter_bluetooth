import 'package:equatable/equatable.dart';

class BikeGoperBroadcast extends Equatable {
  const BikeGoperBroadcast({
    required this.id,
    required this.cadence,
    required this.power,
    required this.resistance,
  });

  final int id;
  final int cadence;
  final int power;
  final int resistance;

  @override
  List<Object?> get props => [id, cadence, power, resistance];
}

const initialBikeGoperBroadcast = BikeGoperBroadcast(
  id: 0,
  cadence: 0,
  power: 0,
  resistance: 0,
);
