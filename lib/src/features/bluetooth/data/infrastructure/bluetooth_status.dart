import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class BluetoothStatus {
  BluetoothState get state;
}

class BluetoothStatusImpl implements BluetoothStatus {
  BluetoothStatusImpl() {
    _flutterReactiveBle.statusStream.listen((event) {
      if (event == BleStatus.ready) {
        bluetoothState = BluetoothState.connected;
      } else {
        bluetoothState = BluetoothState.disconnected;
      }
    });
  }

  // Control Variables
  late BluetoothState bluetoothState;

  // Services
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();

  @override
  BluetoothState get state => bluetoothState;
}
