part of '../application/services/bluetooth_equipment_service.dart';

abstract class BluetoothGuid {
  static Uuid get fitnessMachineService =>
      Uuid.parse('00001826-0000-1000-8000-00805f9b34fb');

  static Uuid get treadmillFitnessData =>
      Uuid.parse('00002acd-0000-1000-8000-00805f9b34fb');

  static Uuid get bikeIndoorData =>
      Uuid.parse('00002ad2-0000-1000-8000-00805f9b34fb');

  static Uuid get frequencyMeterService =>
      Uuid.parse('0000180d-0000-1000-8000-00805f9b34fb');

  static Uuid get frequencyMeterMeasurement =>
      Uuid.parse('00002a37-0000-1000-8000-00805f9b34fb');

  static Uuid get userDataService =>
      Uuid.parse('0000181c-0000-1000-8000-00805f9b34fb');

  static Uuid get userAge => Uuid.parse('00002a80-0000-1000-8000-00805f9b34fb');

  static Uuid get userWeight =>
      Uuid.parse('00002a98-0000-1000-8000-00805f9b34fb');
}
