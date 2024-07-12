import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_shared_preferences_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bike_keiser_cubit/bike_keiser_cubit.dart';

part 'bluetooth_equipment_event.dart';
part 'bluetooth_equipment_state.dart';

class BluetoothEquipmentBloc
    extends Bloc<BluetoothEquipmentEvent, BluetoothEquipmentState> {
  BluetoothEquipmentBloc(
    this._bluetoothSharedPreferencesService,
    this._trainingFlowData,
    this._bikeKeiserCubit,
  ) : super(BluetoothEquipmentInitialState()) {
    on<BluetoothEquipmentConnectEvent>(_connectEquipment);
    on<BluetoothEquipmentConnectBikeEvent>(_trackBike);
    on<BluetoothEquipmentConnectTreadmillEvent>(_trackTreadmill);
    on<BluetoothEquipmentConnectFrequencyMeterEvent>(_trackFrequencyMeter);
    on<BluetoothEquipmentDisconnectEvent>(_disconnectEquipment);
    on<BluetoothEquipmentDisconnectBikeEvent>(_disconnectBike);
    on<BluetoothEquipmentDisconnectTreadmillEvent>(_disconnectTreadmill);
    on<BluetoothEquipmentDisconnectFrequencyMeterEvent>(
        _disconnectFrequencyMeter);
  }

  // Services
  final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;
  final TrainingFlowData _trainingFlowData;
  final BikeKeiserCubit _bikeKeiserCubit;
  final BluetoothEquipmentService _bluetoothEquipmentService =
      BluetoothEquipmentService.instance;

  // Streams
  StreamSubscription<BluetoothDeviceState>? _bikeDeviceStream;
  StreamSubscription<BluetoothDeviceState>? _treadmillDeviceStream;
  StreamSubscription<BluetoothDeviceState>? _frequencyMeterDeviceStream;

  // Variables
  BluetoothDevice? _bikeDevice;
  BluetoothDevice? _treadmillDevice;
  BluetoothDevice? _frequencyMeterDevice;
  List<BluetoothService> _services = [];
  Timer? timer;
  int _retries = 0;

  Future<void> _connectEquipment(
    BluetoothEquipmentConnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {}

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

  void _trackBike(
    BluetoothEquipmentConnectBikeEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) {
    final BluetoothDevice bikeEquipment = event.equipment;

    _bikeDeviceStream = bikeEquipment.state.listen((state) async {
      switch (state) {
        case BluetoothDeviceState.connected:
          _bikeDevice = bikeEquipment;
          Bluetooth.bikeDevice = bikeEquipment;

          emit(BluetoothEquipmentConnected());

          await _bluetoothSharedPreferencesService.bluetoothCryptoBikeGoper(
            bikeId: bikeEquipment.id.id,
          );

          Bluetooth().cleanBikeData();
          Bluetooth.connectedDevices.value = [
            _frequencyMeterDevice != null,
            _bikeDevice != null,
            _treadmillDevice != null,
          ];

          _trainingFlowData.postBikeGraph = true;

          _services = await bikeEquipment.discoverServices();
          if (bikeEquipment.name.contains('ZIYOU')) {
            await Bluetooth().getZiyouBikeData(_services);
          } else {
            await Bluetooth().getIndoorBikeData(_services);
          }
          break;
        case BluetoothDeviceState.disconnected:
          _disconnectBike(_bikeDevice);
          emit(BluetoothEquipmentError(
            error: 'Dispositivo desconectado',
          ));
          break;
        default:
          break;
      }
    });
  }

  void _trackTreadmill(
    BluetoothEquipmentConnectTreadmillEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) {
    final BluetoothDevice treadmillEquipment = event.equipment;

    _treadmillDeviceStream = treadmillEquipment.state.listen((state) async {
      switch (state) {
        case BluetoothDeviceState.connected:
          _treadmillDevice = treadmillEquipment;
          Bluetooth.treadmillDevice = treadmillEquipment;
          emit(BluetoothEquipmentConnected());
          await _bluetoothSharedPreferencesService.bluetoothCryptoTreadmillBLE(
            treadmillId: treadmillEquipment.id.id,
          );
          Bluetooth().cleanTreadmillData();
          Bluetooth.connectedDevices.value = [
            _frequencyMeterDevice != null,
            _bikeDevice != null,
            _treadmillDevice != null,
          ];
          _trainingFlowData.postTreadmillGraph = true;
          _services = await treadmillEquipment.discoverServices();
          await Bluetooth().getTreadmillData(_services);
          break;
        case BluetoothDeviceState.disconnected:
          _disconnectTreadmill(_treadmillDevice);
          emit(BluetoothEquipmentError(
            error: 'Dispositivo desconectado',
          ));
          break;
        default:
          break;
      }
    });
  }

  void _trackFrequencyMeter(
    BluetoothEquipmentConnectFrequencyMeterEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) {
    final BluetoothDevice frequencyMeterEquipment = event.equipment;

    _frequencyMeterDeviceStream =
        frequencyMeterEquipment.state.listen((state) async {
      switch (state) {
        case BluetoothDeviceState.connected:
          _frequencyMeterDevice = frequencyMeterEquipment;
          Bluetooth.heartRateDevice = frequencyMeterEquipment;

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

          _services = await frequencyMeterEquipment.discoverServices();

          await Bluetooth().getUserData(_services, userAge, userWeight);
          await Bluetooth().getHeartRateMeasurement(_services);
          break;
        case BluetoothDeviceState.disconnected:
          await _disconnectFrequencyMeter(_frequencyMeterDevice);
          emit(BluetoothEquipmentError(
            error: 'Dispositivo desconectado',
          ));
          break;
        default:
          break;
      }
    });
  }

  Future<void> _disconnectEquipment(
    BluetoothEquipmentDisconnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    await event.bluetoothEquipment.equipment.disconnect();
    switch (event.bluetoothEquipment.equipmentType) {
      case BluetoothEquipmentType.bikeKeiser:
        add(BluetoothEquipmentDisconnectBikeEvent());
        break;
      case BluetoothEquipmentType.bikeGoper:
        add(BluetoothEquipmentDisconnectBikeEvent());
        break;
      case BluetoothEquipmentType.treadmill:
        add(BluetoothEquipmentDisconnectTreadmillEvent());
      case BluetoothEquipmentType.frequencyMeter:
        add(BluetoothEquipmentDisconnectFrequencyMeterEvent());
        break;
      default:
        break;
    }
  }

  Future<void> _disconnectBike(
    BluetoothEquipmentDisconnectBikeEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
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

  Future<void> _disconnectTreadmill(
    BluetoothEquipmentDisconnectTreadmillEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    _treadmillDevice = null;
    _bluetoothEquipmentService.treadmillService.cleanTreadmillData();
  }

  Future<void> _disconnectFrequencyMeter(
    BluetoothEquipmentDisconnectFrequencyMeterEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    _frequencyMeterDevice = null;
    Bluetooth.heartRateDevice = null;
    Bluetooth().cleanHeartRateData();
    Bluetooth.connectedDevices.value = [
      _frequencyMeterDevice != null,
      _bikeDevice != null,
      _treadmillDevice != null,
    ];
  }

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
}
