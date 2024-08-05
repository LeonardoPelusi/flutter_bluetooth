part of '../bluetooth_serializer.dart';

final bikeGoperBroadcastSerializer = BikeGoperBroadcastSerializer();

class BikeGoperBroadcastSerializer
    implements BluetoothSerializer<BikeGoperBroadcast, Uint8List> {
  @override
  BikeGoperBroadcast from(Uint8List manufacturerData) {
    final cadence = parseHexToInt(manufacturerData[5], manufacturerData[6]);
    final power = parseHexToInt(manufacturerData[3], manufacturerData[4]);
    final resistance = manufacturerData[7];
    final result = BikeGoperBroadcast(
      cadence: cadence,
      power: power,
      resistance: resistance,
    );
    return result;
  }

  @override
  to(BikeGoperBroadcast object) {
    throw UnimplementedError();
  }
}
