part of '../bluetooth_serializer.dart';

final frequencyMeterBroadcastSerializer = FrequencyMeterBroadcastSerializer();

class FrequencyMeterBroadcastSerializer
    implements BluetoothSerializer<FrequencyMeterBroadcast, Uint8List> {
  @override
  FrequencyMeterBroadcast from(List<int> bikeData) {
    if (bikeData.isEmpty) return initialFrequencyMeterBroadcast;

    late int bpmValue;

    if (bikeData.length > 1) {
      bpmValue = bikeData[1];
    } else {
      bpmValue = 0;
    }

    final result = FrequencyMeterBroadcast(
      bpm: bpmValue,
    );
    return result;
  }

  @override
  to(FrequencyMeterBroadcast object) {
    throw UnimplementedError();
  }
}
