import 'package:equatable/equatable.dart';

class FrequencyMeterDirectConnect extends Equatable {
  const FrequencyMeterDirectConnect({
    required this.bpm,
  });

  final int bpm;

  @override
  List<Object?> get props => [bpm];
}

const initialFrequencyMeterDirectConnect = FrequencyMeterDirectConnect(
  bpm: 0,
);
