import 'package:equatable/equatable.dart';

class BikeKeiserBroadcast extends Equatable {
  const BikeKeiserBroadcast({
    required this.id,
    required this.cadence,
    required this.power,
    required this.gear,
    required this.kcal,
  });

  final String id;
  final int cadence;
  final int power;
  final int gear;
  final int kcal;

  @override
  List<Object?> get props => [id, cadence, power, gear, kcal];
}

const initialBikeKeiserBroadcast = BikeKeiserBroadcast(
  id: '',
  cadence: 0,
  power: 0,
  gear: 0,
  kcal: 0,
);
