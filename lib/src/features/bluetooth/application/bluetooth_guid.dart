part of 'services/bluetooth_equipment_service.dart';

abstract class BluetoothGuid {
  Guid get fitnessMachineService;

  Guid get treadmillFitnessData;

  Guid get frequencyMeterService;

  Guid get frequencyMeterMeasurement;

  Guid get userDataService;

  Guid get userAge;

  Guid get userWeight;
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

  @override
  Guid get treadmillFitnessData => Guid('00002acd-0000-1000-8000-00805f9b34fb');

  @override
  Guid get frequencyMeterService => Guid('0000180d-0000-1000-8000-00805f9b34fb');

  @override
  Guid get frequencyMeterMeasurement =>
      Guid('00002a37-0000-1000-8000-00805f9b34fb');

  @override
  Guid get userDataService => Guid('0000181c-0000-1000-8000-00805f9b34fb');

  @override
  Guid get userAge => Guid('00002a80-0000-1000-8000-00805f9b34fb');

  @override
  Guid get userWeight => Guid('00002a98-0000-1000-8000-00805f9b34fb');
}
