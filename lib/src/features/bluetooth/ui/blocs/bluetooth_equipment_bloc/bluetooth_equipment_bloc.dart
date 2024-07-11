import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_model.dart';

part 'bluetooth_equipment_event.dart';
part 'bluetooth_equipment_state.dart';

class BluetoothEquipmentBloc
    extends Bloc<BluetoothEquipmentEvent, BluetoothEquipmentState> {
  BluetoothEquipmentBloc() : super(BluetoothEquipmentInitialState()) {
    on<BluetoothEquipmentConnectEvent>(_connectEquipment);
    on<BluetoothEquipmentDisconnectEvent>(_disconnectEquipment);
    on<BluetoothEquipmentConnectBike>(_trackBike);
    on<BluetoothEquipmentConnectTreadmill>(_trackTreadmill);
    on<BluetoothEquipmentConnectFrequencyMeter>(_trackFrequencyMeter);
  }

  StreamSubscription<BluetoothDeviceState>? _bikeDeviceStream;
  StreamSubscription<BluetoothDeviceState>? _treadmillDeviceStream;
  StreamSubscription<BluetoothDeviceState>? _frequencyMeterDeviceStream;

  Future<void> _connectEquipment(
    BluetoothEquipmentConnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {}

  Future<void> _disconnectEquipment(
    BluetoothEquipmentDisconnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {}

  void _trackBike(
    BluetoothEquipmentConnectBike event,
    Emitter<BluetoothEquipmentState> emit,
  ) {
    _bikeDeviceStream = deviceWithId.device.state.listen((event) async {
      if (event == BluetoothDeviceState.connected) {
        _bikeDevice = deviceWithId;
        Bluetooth.bikeDevice = deviceWithId;

        emit(BluetoothEquipmentConnected());

        await _bluetoothSharedPreferencesService.bluetoothCryptoBikeGoper(
          bikeId: deviceWithId.device.id.id,
        );

        Bluetooth().cleanBikeData();
        Bluetooth.connectedDevices.value = [
          _frequencyMeterDevice != null,
          _bikeDevice != null,
          _treadmillDevice != null,
        ];

        _trainingFlowData.postBikeGraph = true;

        _services = await deviceWithId.device.discoverServices();
        if (deviceWithId.device.name.contains('ZIYOU')) {
          await Bluetooth().getZiyouBikeData(_services);
        } else {
          await Bluetooth().getIndoorBikeData(_services);
        }
      }

      if (event == BluetoothDeviceState.disconnected && _bikeDevice != null) {
        _disconnectBike(_bikeDevice);
        emit(BluetoothEquipmentError(
          error: 'Dispositivo desconectado',
        ));
      }
    });
  }

  void _trackTreadmill(
    BluetoothEquipmentConnectTreadmill event,
    Emitter<BluetoothEquipmentState> emit,
  ) {
    _treadmillDeviceStream = deviceWithId.device.state.listen((event) async {
      if (event == BluetoothDeviceState.disconnected) {
        _disconnectTreadmill(_treadmillDevice);
        emit(BluetoothEquipmentError(
          error: 'Dispositivo desconectado',
        ));
      }
      if (event == BluetoothDeviceState.connected) {
        _treadmillDevice = deviceWithId;
        Bluetooth.treadmillDevice = deviceWithId;

        emit(BluetoothEquipmentConnected());

        await _bluetoothSharedPreferencesService.bluetoothCryptoTreadmillBLE(
          treadmillId: deviceWithId.device.id.id,
        );

        Bluetooth().cleanTreadmillData();
        Bluetooth.connectedDevices.value = [
          _frequencyMeterDevice != null,
          _bikeDevice != null,
          _treadmillDevice != null,
        ];

        _trainingFlowData.postTreadmillGraph = true;

        _services = await deviceWithId.device.discoverServices();
        await Bluetooth().getTreadmillData(_services);
      }
    });
  }

  void _trackFrequencyMeter(
    BluetoothEquipmentConnectFrequencyMeter event,
    Emitter<BluetoothEquipmentState> emit,
  ) {
    _frequencyMeterDeviceStream =
        event.equipment.equipment.state.listen((event) async {
      if (event == BluetoothDeviceState.disconnected) {
        await _disconnectFrequencyMeter(_frequencyMeterDevice);

        emit(BluetoothEquipmentError(
          error: 'Dispositivo desconectado',
        ));
      }
      if (event == BluetoothDeviceState.connected) {
        _frequencyMeterDevice = deviceWithId;
        Bluetooth.heartRateDevice = deviceWithId;

        emit(BluetoothEquipmentConnected());

        Bluetooth().cleanHeartRateData();

        Bluetooth.connectedDevices.value = [
          _frequencyMeterDevice != null,
          _bikeDevice != null,
          _treadmillDevice != null,
        ];

        _trainingFlowData.postBpmGraph = true;
        int userAge = _trainingFlowData.userAge!;
        double userWeight = _trainingFlowData.userWeight!;

        _services = await deviceWithId.device.discoverServices();

        await Bluetooth().getUserData(_services, userAge, userWeight);
        await Bluetooth().getHeartRateMeasurement(_services);
      }
    });
  }

  Future<void> _disconnectBike(DeviceWithId? deviceWithId) async {
    if (deviceWithId != null) {
      await deviceWithId.device.disconnect();
    }
    _bikeDevice = null;
    Bluetooth.bikeDevice = null;

    if (Bluetooth.broadcastKeiser.value) {
      Bluetooth.broadcastKeiser.value = false;
      timer?.cancel();
    }
    Bluetooth().cleanBikeData();
    Bluetooth.connectedDevices.value = [
      _frequencyMeterDevice != null,
      _bikeDevice != null,
      _treadmillDevice != null,
    ];
  }

  Future<void> _disconnectTreadmill(DeviceWithId? deviceWithId) async {
    if (deviceWithId != null) {
      await deviceWithId.device.disconnect();
    }
    _treadmillDevice = null;
    Bluetooth.treadmillDevice = null;
    Bluetooth().cleanTreadmillData();
    Bluetooth.connectedDevices.value = [
      _frequencyMeterDevice != null,
      _bikeDevice != null,
      _treadmillDevice != null,
    ];
  }

  Future<void> _disconnectFrequencyMeter(DeviceWithId? deviceWithId) async {
    if (deviceWithId != null) {
      await deviceWithId.device.disconnect();
    }
    _frequencyMeterDevice = null;
    Bluetooth.heartRateDevice = null;
    Bluetooth().cleanHeartRateData();
    Bluetooth.connectedDevices.value = [
      _frequencyMeterDevice != null,
      _bikeDevice != null,
      _treadmillDevice != null,
    ];
  }
}
