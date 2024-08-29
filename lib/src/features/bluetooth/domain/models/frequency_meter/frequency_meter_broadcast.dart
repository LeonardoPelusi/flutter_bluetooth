import 'package:equatable/equatable.dart';

class FrequencyMeterBroadcast extends Equatable {
  const FrequencyMeterBroadcast({
    required this.bpm,
  });

  final int bpm;

  @override
  List<Object?> get props => [bpm];
}

const initialFrequencyMeterBroadcast = FrequencyMeterBroadcast(
  bpm: 0,
);
