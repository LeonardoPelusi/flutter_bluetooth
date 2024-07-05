import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'bluetooth_treadmill_service.dart';

part 'bluetooth_guid.dart';

class BluetoothServices {
  static BluetoothGuid get guids => _BluetoothGuid();
}
