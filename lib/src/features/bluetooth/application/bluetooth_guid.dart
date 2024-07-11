part of 'services/bluetooth_equipment_service.dart';

abstract class BluetoothGuid {
  Guid get fitnessMachineService;

  // ESTEIRA BLE
  Guid get treadmillFitnessData;
}

class _BluetoothGuid implements BluetoothGuid {
  _BluetoothGuid._internal();

  static final _BluetoothGuid _singleton = _BluetoothGuid._internal();

  factory _BluetoothGuid() {
    return _singleton;
  }

  @override
  Guid get fitnessMachineService =>
      Guid('00001826-0000-1000-8000-00805f9b34fb');

  // ESTEIRA BLE
  @override
  Guid get treadmillFitnessData => Guid('00002acd-0000-1000-8000-00805f9b34fb');
}
