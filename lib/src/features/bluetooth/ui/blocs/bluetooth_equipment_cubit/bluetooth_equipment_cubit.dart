import 'dart:async';

import 'package:goper/helpers/bluetooth_helper.dart';
import 'package:goper/models/bluetooth/bluetooth_shared_preferences.dart';
import 'package:goper/services/bluetooth/bluetooth_shared_preferences_service.dart';
import 'package:goper/src/features/training/training_flow_data.dart';
import 'package:goper/values/shared_preferences.dart';
import 'package:goper_ui/goper_ui.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'bluetooth_equipment_state.dart';

abstract class BluetoothEquipmentCubit extends Cubit<BluetoothEquipmentState> {
  BluetoothEquipmentCubit() : super(BluetoothEquipmentInitial());

  Future<void> connectDevice(DeviceWithId deviceWithId, {bool resetRetries});
  void disconnectBluetooth({bool closingTraining});
}

class BluetoothEquipmentCubitImpl extends BluetoothEquipmentCubit {
  BluetoothEquipmentCubitImpl(
    this._bluetoothSharedPreferencesService,
    this._trainingFlowData,
    this._bikeKeiserCubit,
  ) : super();

  final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;
  final TrainingFlowData _trainingFlowData;
  final BikeKeiserCubit _bikeKeiserCubit;

  int _retries = 0;

  DeviceWithId? _bikeDevice;
  DeviceWithId? _treadmillDevice;
  DeviceWithId? _frequencyMeterDevice;

  StreamSubscription<BluetoothDeviceState>? _bikeDeviceStream;
  StreamSubscription<BluetoothDeviceState>? _treadmillDeviceStream;
  StreamSubscription<BluetoothDeviceState>? _frequencyMeterDeviceStream;

  List<BluetoothService> _services = [];

  Timer? timer;

  @override
  Future<void> connectDevice(
    DeviceWithId deviceWithId, {
    bool resetRetries = false,
  }) async {
    if (resetRetries) {
      _retries = 0;
    }
    emit(BluetoothEquipmentConnecting(connectingEquipments: [
      ...state.connectingEquipments,
      deviceWithId,
    ]));

    if (deviceWithId.equipmentType == BluetothEquipmentType.bike &&
        _bikeDevice != null) {
      await _disconnectBike(_bikeDevice!);
    } else if (deviceWithId.equipmentType == BluetothEquipmentType.treadmill &&
        _treadmillDevice != null) {
      await _disconnectTreadmill(_treadmillDevice!);
    } else if (deviceWithId.equipmentType ==
            BluetothEquipmentType.frequence_meter &&
        _frequencyMeterDevice != null) {
      await _disconnectFrequencyMeter(_frequencyMeterDevice!);
    }

    if (BluetoothHelper.broadcastValidation(deviceWithId.device)) {
      _broadcastKeiser(deviceWithId);
    } else {
      bool _timeOut = false;
      bool _error = false;
      _retries += 1;

      try {
        await deviceWithId.device
            .connect(timeout: Duration(seconds: 10))
            .timeout(Duration(seconds: 10), onTimeout: () async {
          _timeOut = true;

          if (_retries <= 2) {
            //RETRY CONNECTION
            if (deviceWithId.equipmentType == BluetothEquipmentType.bike &&
                _bikeDevice != deviceWithId) {
              await connectDevice(deviceWithId);
            } else if (deviceWithId.equipmentType ==
                    BluetothEquipmentType.treadmill &&
                _treadmillDevice != deviceWithId) {
              await connectDevice(deviceWithId);
            } else if (deviceWithId.equipmentType ==
                    BluetothEquipmentType.frequence_meter &&
                _frequencyMeterDevice != deviceWithId) {
              await connectDevice(deviceWithId);
            }
          } else {
            emit(BluetoothEquipmentTimeExpiredError(
              error: 'Não foi possivel realizar a conexão',
            ));
          }
        });
      } catch (e) {
        _error = true;
        if (e == 'already_connected') {
          emit(BluetoothEquipmentError(
            error: 'Dispositivo já conectado',
          ));
        } else {
          emit(BluetoothEquipmentError(
            error: 'Não foi possivel realizar a conexão',
          ));
        }
        rethrow;
      } finally {
        if (!_timeOut && !_error) {
          if (deviceWithId.equipmentType == BluetothEquipmentType.bike) {
            _trackBike(deviceWithId);
          } else if (deviceWithId.equipmentType ==
              BluetothEquipmentType.treadmill) {
            _trackTreadmill(deviceWithId);
          } else if (deviceWithId.equipmentType ==
              BluetothEquipmentType.frequence_meter) {
            _trackFrequencyMeter(deviceWithId);
          }

          _retries = 0;
        }
      }
    }
  }

  @override
  void disconnectBluetooth({bool closingTraining = true}) {
    _bikeDevice?.device.disconnect();
    _bikeDeviceStream?.cancel();
    _treadmillDevice?.device.disconnect();
    _treadmillDeviceStream?.cancel();
    _frequencyMeterDevice?.device.disconnect();
    _frequencyMeterDeviceStream?.cancel();
    _bikeDevice = null;
    _treadmillDevice = null;
    _frequencyMeterDevice = null;
    Bluetooth.bikeDevice = null;
    Bluetooth.treadmillDevice = null;
    Bluetooth.heartRateDevice = null;
    Bluetooth().cleanBikeData();
    Bluetooth().cleanHeartRateData();
    Bluetooth().cleanTreadmillData();
    Bluetooth.connectedDevices.value = [false, false, false];
    Bluetooth.heartRateConnected.value =
        HeartRateBleController(deviceConnected: false, open: true);
    Bluetooth.bikeConnected.value = BikeBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.treadmillConnected.value = TreadmillBleController(
        deviceConnected: false, openBox: true, openFooter: true);
    Bluetooth.bleOn.value = false;
    _bikeKeiserCubit.cancelBikeKeiserBroadcastDetection();
    _bikeKeiserCubit.deinitialize();
    if (closingTraining) {
      _bikeKeiserCubit.close();
    }
    timer?.cancel();
  }

  @override
  Future<void> close() async {
    disconnectBluetooth();
    super.close();
  }

  void _broadcastKeiser(DeviceWithId deviceWithId) {
    Future.delayed(Duration(milliseconds: 200), () {
      Bluetooth.broadcastKeiser.value = true;

      // cancelar broadcast anterior, se houver
      _bikeKeiserCubit.cancelBikeKeiserBroadcastDetection();
      // inicicar listen do broadcast da nova bike selecionada
      _bikeKeiserCubit.newBroadcastRequested();
      _bikeKeiserCubit.listenToBikeKeiserBroadcast(bikeId: deviceWithId.id);

      // é necessário reiniciar o broadcast depois de 30min
      timer?.cancel();
      timer = Timer(Duration(minutes: 26), () {
        _bikeKeiserCubit.listenToBikeKeiserBroadcast(bikeId: deviceWithId.id);
      });

      _bikeDevice = deviceWithId;
      Bluetooth.bikeDevice = deviceWithId;

      _bluetoothSharedPreferencesService.bluetoothCryptoBikeKeiser(
        bikeKeiserId: deviceWithId.device.id.id,
      );

      Bluetooth().cleanBikeData();

      Bluetooth.connectedDevices.value = [
        _frequencyMeterDevice != null,
        _bikeDevice != null,
        _treadmillDevice != null,
      ];

      _trainingFlowData.postBikeGraph = true;

      emit(BluetoothEquipmentConnected());
    });
  }

  

  
}
