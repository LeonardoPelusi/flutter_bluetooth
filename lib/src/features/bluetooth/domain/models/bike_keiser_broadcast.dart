import 'package:equatable/equatable.dart';

class BikeKeiserBroadcast extends Equatable {
  const BikeKeiserBroadcast({
    required this.cadence,
    required this.power,
    required this.gear,
    required this.kcal,
  });

  final int cadence;
  final int power;
  final int gear;
  final int kcal;

  @override
  List<Object?> get props => [cadence, power, gear, kcal];
}

const initialBikeKeiserBroadcast = BikeKeiserBroadcast(
  cadence: 0,
  power: 0,
  gear: 0,
  kcal: 0,
);
