part of '../bluetooth_serializer.dart';

final frequencyMeterDirectConnectSerializer = FrequencyMeterDirectConnectSerializer();

class FrequencyMeterDirectConnectSerializer
    implements BluetoothSerializer<FrequencyMeterDirectConnect, Uint8List> {
  @override
  FrequencyMeterDirectConnect from(List<int> bikeData) {
    if (bikeData.isEmpty) return initialFrequencyMeterDirectConnect;

    late int bpmValue;

    if (bikeData.length > 1) {
      bpmValue = bikeData[1];
    } else {
      bpmValue = 0;
    }

    final result = FrequencyMeterDirectConnect(
      bpm: bpmValue,
    );
    return result;
  }

  @override
  to(FrequencyMeterDirectConnect object) {
    throw UnimplementedError();
  }
}
