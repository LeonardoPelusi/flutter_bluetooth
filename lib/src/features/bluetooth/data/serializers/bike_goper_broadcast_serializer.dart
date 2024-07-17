part of 'serializers.dart';

class BikeGoperBroadcastSerializer {
  static BikeGoperBroadcast from(Uint8List manufacturerData) {
    final id = manufacturerData[2];
    final cadence = parseHexToInt(manufacturerData[5], manufacturerData[6]);
    final power = parseHexToInt(manufacturerData[3], manufacturerData[4]);
    final resistance = manufacturerData[7];
    final result = BikeGoperBroadcast(
      id: id,
      cadence: cadence,
      power: power,
      resistance: resistance,
    );
    return result;
  }

  static BluetoothEquipmentModel to(BikeGoperBroadcast model) {
    throw UnimplementedError();
  }
}

final bikeGoperBroadcastsSerializer = BikeGoperBroadcastSerializer();
