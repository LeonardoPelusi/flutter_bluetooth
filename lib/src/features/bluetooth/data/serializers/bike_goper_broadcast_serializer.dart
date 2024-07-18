part of 'bluetooth_serializer.dart';

// !ATENÇÃO
// -> NO FLUTTER BLUE PLUS, NO MANUFACTURER DATA NÃO VEM OS DOIS PRIMEIROS BYTES,
//  PORTANTO IREMOS DESCONSIDERÁ-LOS NA HORA DA TRADUÇÃO.

class BikeGoperBroadcastSerializer
    implements BluetoothSerializer<BikeGoperBroadcast, Uint8List> {
  @override
  BikeGoperBroadcast from(Uint8List manufacturerData) {
    final id = manufacturerData[2 - 2];
    final cadence = parseHexToInt(manufacturerData[5 - 2], manufacturerData[6 - 2]);
    final power = parseHexToInt(manufacturerData[3 - 2], manufacturerData[4 - 2]);
    final resistance = manufacturerData[7 - 2];
    final result = BikeGoperBroadcast(
      id: id,
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

final bikeGoperBroadcastSerializer = BikeGoperBroadcastSerializer();
