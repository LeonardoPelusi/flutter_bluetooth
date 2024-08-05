import 'package:equatable/equatable.dart';

class FrequencyMeterBluetooth extends Equatable {
  const FrequencyMeterBluetooth({
    required this.bpm,
  });

  final int bpm;

  @override
  List<Object?> get props => [bpm];
}

const initialFrequencyMeterBluetooth = FrequencyMeterBluetooth(
  bpm: 0,
);
