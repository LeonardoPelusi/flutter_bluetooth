part of '../bluetooth_serializer.dart';

final frequencyMeterBluetoothSerializer = FrequencyMeterBluetoothSerializer();

class FrequencyMeterBluetoothSerializer
    implements BluetoothSerializer<FrequencyMeterBluetooth, Uint8List> {
  @override
  FrequencyMeterBluetooth from(List<int> bikeData) {
    if (bikeData.isEmpty) return initialFrequencyMeterBluetooth;

    late int bpmValue;

    if (bikeData.length > 1) {
      bpmValue = bikeData[1];
    } else {
      bpmValue = 0;
    }

    final result = FrequencyMeterBluetooth(
      bpm: bpmValue,
    );
    return result;
  }

  @override
  to(FrequencyMeterBluetooth object) {
    throw UnimplementedError();
  }
}
