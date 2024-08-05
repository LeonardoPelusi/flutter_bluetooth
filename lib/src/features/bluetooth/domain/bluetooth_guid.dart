part of '../application/services/bluetooth_equipment_service.dart';

abstract class BluetoothGuid {
  Uuid get fitnessMachineService;

  Uuid get treadmillFitnessData;

  Uuid get bikeIndoorData;

  Uuid get frequencyMeterService;

  Uuid get frequencyMeterMeasurement;

  Uuid get userDataService;

  Uuid get userAge;

  Uuid get userWeight;
}

class _BluetoothGuid implements BluetoothGuid {
  _BluetoothGuid._internal();

  static final _BluetoothGuid _singleton = _BluetoothGuid._internal();

  factory _BluetoothGuid() {
    return _singleton;
  }

  @override
  Uuid get fitnessMachineService =>
      Uuid.parse('00001826-0000-1000-8000-00805f9b34fb');

  @override
  Uuid get treadmillFitnessData =>
      Uuid.parse('00002acd-0000-1000-8000-00805f9b34fb');

  @override
  Uuid get bikeIndoorData => Uuid.parse('00002ad2-0000-1000-8000-00805f9b34fb');

  @override
  Uuid get frequencyMeterService =>
      Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb');

  @override
  Uuid get frequencyMeterMeasurement =>
      Uuid.parse('00002a37-0000-1000-8000-00805f9b34fb');

  @override
  Uuid get userDataService =>
      Uuid.parse('0000181c-0000-1000-8000-00805f9b34fb');

  @override
  Uuid get userAge => Uuid.parse('00002a80-0000-1000-8000-00805f9b34fb');

  @override
  Uuid get userWeight => Uuid.parse('00002a98-0000-1000-8000-00805f9b34fb');
}
