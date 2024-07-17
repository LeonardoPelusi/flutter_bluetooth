part of 'serializers.dart';

// !DOCUMENTATION:
// -> BIKE KEISER: https://dev.keiser.com/mseries/direct/

class BikeKeiserBroadcastSerializer {
  static BikeKeiserBroadcast from(Uint8List manufacturerData) {
    try {
      final kcal = parseHexToInt(manufacturerData[13], manufacturerData[12]);
      final id = manufacturerData[5].toString();
      final dataType = manufacturerData[4];
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
          parseHexToInt(manufacturerData[7], manufacturerData[6]) * 0.1;
      final power = parseHexToInt(manufacturerData[11], manufacturerData[10]);
      // final gear = manufacturerData[18];
      final gear = manufacturerData[16];
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

  static bool _isRealTimeValues(int dataType) {
    return dataType == 0 || (dataType >= 128 && dataType <= 227);
  }

  static to(BikeKeiserBroadcast object) {
    throw UnimplementedError();
  }
}

final bikeKeiserBroadcastSerializer = BikeKeiserBroadcastSerializer();
