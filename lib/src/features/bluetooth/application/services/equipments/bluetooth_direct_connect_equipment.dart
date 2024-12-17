import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

abstract class BluetoothDirectConnectEquipment {
  Future<void> getDataFromServices(List<Service> services);
  Future<void> cleanData();
}
