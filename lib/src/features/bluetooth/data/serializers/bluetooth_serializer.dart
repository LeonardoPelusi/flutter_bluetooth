import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_bluetooth/helper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_goper_direct_connect.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_goper_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bike/bike_keiser_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/frequency_meter/frequency_meter_bluetooth.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/frequency_meter/frequency_meter_broadcast.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/treadmill/treadmill_bluetooth.dart';

// Bikes
part 'bike/bike_goper_direct_connect_serializer.dart';
part 'bike/bike_goper_broadcast_serializer.dart';
part 'bike/bike_keiser_broadcast_serializer.dart';

// Treadmills
part 'treadmill/treadmill_bluetooth_serializer.dart';

// Frequency Meters
part 'frequency_meter/frequency_meter_bluetooth_serializer.dart';
part 'frequency_meter/frequency_meter_broadcast_serializer.dart';

/// Middleware that parses a type [T] to/from a JSON representation in [Map].
abstract class BluetoothSerializer<T extends Object, U> {
  T from(U json);
  U to(T object);
}
