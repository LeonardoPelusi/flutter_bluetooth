import 'dart:async';
import 'dart:typed_data';

abstract class BluetoothBroadcastEquipment {
  Future<void> getDataFromManufacturerData(Uint8List manufacturerData);
  Future<void> cleanData();
}
