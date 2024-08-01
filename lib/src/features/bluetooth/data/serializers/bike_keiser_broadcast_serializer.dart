part of 'bluetooth_serializer.dart';

// !DOCUMENTATION:
// -> BIKE KEISER: https://dev.keiser.com/mseries/direct/

// !ATENÇÃO
// -> NO FLUTTER BLUE PLUS, NO MANUFACTURER DATA NÃO VEM OS DOIS PRIMEIROS BYTES,
//  PORTANTO IREMOS DESCONSIDERÁ-LOS NA HORA DA TRADUÇÃO.

final bikeKeiserBroadcastSerializer = BikeKeiserBroadcastSerializer();

class BikeKeiserBroadcastSerializer
    implements BluetoothSerializer<BikeKeiserBroadcast, Uint8List> {
  @override
  BikeKeiserBroadcast from(Uint8List manufacturerData) {
    try {
      final kcal =
          parseHexToInt(manufacturerData[13 - 2], manufacturerData[12 - 2]);
      final id = manufacturerData[5 - 2].toString();
      final dataType = manufacturerData[4 - 2];
      if (!_isRealTimeValues(dataType)) {
        return BikeKeiserBroadcast(
          id: id,
          cadence: 0,
          power: 0,
          gear: 0,
          kcal: kcal,
        );
      }
      final cadence =
          parseHexToInt(manufacturerData[7 - 2], manufacturerData[6 - 2]) * 0.1;
      final power =
          parseHexToInt(manufacturerData[11 - 2], manufacturerData[10 - 2]);
      final gear = manufacturerData[18 - 2];
      return BikeKeiserBroadcast(
        id: id,
        cadence: cadence.round(),
        power: power,
        gear: gear,
        kcal: kcal,
      );
    } catch (_) {
      // throw SerializationError();
      throw UnimplementedError();
    }
  }

  @override
  to(BikeKeiserBroadcast object) {
    throw UnimplementedError();
  }

  static bool _isRealTimeValues(int dataType) {
    return dataType == 0 || (dataType >= 128 && dataType <= 227);
  }
}
