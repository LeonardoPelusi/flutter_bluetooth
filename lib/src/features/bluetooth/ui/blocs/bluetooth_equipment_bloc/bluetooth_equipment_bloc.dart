import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/bluetooth_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/bluetooth_helper.dart';
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
      //!TODO implementar shared preferences
      // this._bluetoothSharedPreferencesService,
      // this._trainingFlowData,
      // this._bikeKeiserCubit,
      )
      : super(BluetoothEquipmentInitialState()) {
    on<BluetoothEquipmentConnectEvent>(_connectEquipment);
    on<BluetoothEquipmentConnectValidatorEvent>(_connectValidator);
    on<BluetoothEquipmentBroadcastConnectEvent>(_broadcastConnect);
    on<BluetoothEquipmentDirectConnectEvent>(_directConnect);
    on<BluetoothEquipmentTrackEvent>(_trackEquipmentState);
    on<BluetoothEquipmentDisconnectEvent>(_disconnectEquipment);
  }

  // Services
  // final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;
  // final TrainingFlowData _trainingFlowData;
  // final BikeKeiserCubit _bikeKeiserCubit;

  // Bluetooth Services
  final BluetoothBikeService _bleBikeService =
      BluetoothEquipmentService.instance.bikeService;
  final BluetoothTreadmillService _bleTreadmillService =
      BluetoothEquipmentService.instance.treadmillService;
  final BluetoothFrequencyMeterService _bleFrequencyMeterService =
      BluetoothEquipmentService.instance.frequencyMeterService;

  // Variables
  Timer? timer;
  final Duration _directConnectionTimeoutDuration = const Duration(seconds: 10);

  Future<void> _connectEquipment(
    BluetoothEquipmentConnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;

    emit(BluetoothEquipmentConnectingState(
      connectingEquipment: bluetoothEquipment,
    ));

    add(BluetoothEquipmentConnectValidatorEvent(
      bluetoothEquipment: bluetoothEquipment,
    ));

    // !TODO implementar lógica broadcast
    if (BluetoothHelper.bikeKeiserValidation(bluetoothEquipment.equipment)) {
      add(BluetoothEquipmentBroadcastConnectEvent(
        bluetoothEquipment: bluetoothEquipment,
      ));
    } else {
      add(BluetoothEquipmentDirectConnectEvent(
        bluetoothEquipment: bluetoothEquipment,
      ));
    }
  }

  Future<void> _connectValidator(
    BluetoothEquipmentConnectValidatorEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    switch (event.bluetoothEquipment.equipmentType) {
      case BluetoothEquipmentType.bikeGoper ||
            BluetoothEquipmentType.bikeKeiser:
        if (_bleBikeService.connectedBike != null) {
          add(BluetoothEquipmentDisconnectEvent(
            bluetoothEquipment: _bleBikeService.connectedBike!,
          ));
        }
        break;
      case BluetoothEquipmentType.treadmill:
        if (_bleTreadmillService.connectedTreadmill != null) {
          add(BluetoothEquipmentDisconnectEvent(
            bluetoothEquipment: _bleTreadmillService.connectedTreadmill!,
          ));
        }
        break;
      case BluetoothEquipmentType.frequencyMeter:
        if (_bleFrequencyMeterService.connectedFrequencyMeter != null) {
          add(BluetoothEquipmentDisconnectEvent(
            bluetoothEquipment:
                _bleFrequencyMeterService.connectedFrequencyMeter!,
          ));
        }
        break;
      default:
        break;
    }
  }

  Future<void> _broadcastConnect(
    BluetoothEquipmentBroadcastConnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;
    switch (event.bluetoothEquipment.equipmentType) {
      case BluetoothEquipmentType.bikeKeiser:
        Future.delayed(const Duration(milliseconds: 200), () {
          Bluetooth.broadcastKeiser.value = true;
          // cancelar broadcast anterior, se houver
          // _bikeKeiserCubit.cancelBikeKeiserBroadcastDetection();
          // // inicicar listen do broadcast da nova bike selecionada
          // _bikeKeiserCubit.newBroadcastRequested();
          // _bikeKeiserCubit.listenToBikeKeiserBroadcast(
          //     bikeId: bluetoothEquipment.id);
          // é necessário reiniciar o broadcast depois de 30min
          timer?.cancel();
          timer = Timer(const Duration(minutes: 26), () {
            // _bikeKeiserCubit.listenToBikeKeiserBroadcast(
            //   bikeId: bluetoothEquipment.id,
            // );
          });

          _bleBikeService.disconnectBike();
          _bleBikeService.connectedBike = bluetoothEquipment;
          // _bluetoothSharedPreferencesService.bluetoothCryptoBikeKeiser(
          //   bikeKeiserId: bluetoothEquipment.equipment.id.id,
          // );
          // _trainingFlowData.postBikeGraph = true;
        });
        break;
      case BluetoothEquipmentType.bikeGoper:
        _bleBikeService.disconnectBike();
        break;
      default:
        break;
    }
    emit(
      BluetoothEquipmentConnectedState(connectedEquipment: bluetoothEquipment),
    );
  }

  Future<void> _directConnect(
    BluetoothEquipmentDirectConnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;

    bool timeOut = false;
    bool error = false;

    try {
      await bluetoothEquipment.equipment.connect().timeout(
        _directConnectionTimeoutDuration,
        onTimeout: () async {
          timeOut = true;

          if (event.retries <= 2) {
            //RETRY CONNECTION
            switch (bluetoothEquipment.equipmentType) {
              case BluetoothEquipmentType.bikeGoper:
                if (bluetoothEquipment != _bleBikeService.connectedBike) {
                  add(BluetoothEquipmentDirectConnectEvent(
                    bluetoothEquipment: bluetoothEquipment,
                    retries: event.retries + 1,
                  ));
                }
                break;
              case BluetoothEquipmentType.treadmill:
                if (bluetoothEquipment !=
                    _bleTreadmillService.connectedTreadmill) {
                  add(BluetoothEquipmentDirectConnectEvent(
                    bluetoothEquipment: bluetoothEquipment,
                    retries: event.retries + 1,
                  ));
                }
                break;
              case BluetoothEquipmentType.frequencyMeter:
                if (bluetoothEquipment !=
                    _bleFrequencyMeterService.connectedFrequencyMeter) {
                  add(BluetoothEquipmentDirectConnectEvent(
                    bluetoothEquipment: bluetoothEquipment,
                    retries: event.retries + 1,
                  ));
                }
                break;
              default:
                break;
            }
          } else {
            emit(BluetoothEquipmentErrorState(
              message: 'Não foi possivel realizar a conexão',
            ));
          }
        },
      );
    } catch (e) {
      error = true;
      if (e == 'already_connected') {
        emit(BluetoothEquipmentErrorState(
          message: 'Dispositivo já conectado',
        ));
      } else {
        emit(BluetoothEquipmentErrorState(
          message: 'Não foi possivel realizar a conexão',
        ));
      }
      rethrow;
    } finally {
      if (!timeOut && !error) {
        add(BluetoothEquipmentTrackEvent(
          bluetoothEquipment: bluetoothEquipment,
        ));
      }
    }
  }

  void _trackEquipmentState(
    BluetoothEquipmentTrackEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;

    await emit.onEach(
      bluetoothEquipment.equipment.state,
      onData: (state) async {
        switch (state) {
          case BluetoothDeviceState.connected:
            emit(BluetoothEquipmentConnectedState(
              connectedEquipment: bluetoothEquipment,
            ));
            List<BluetoothService> services =
                await bluetoothEquipment.equipment.discoverServices();
            switch (bluetoothEquipment.equipmentType) {
              case BluetoothEquipmentType.bikeGoper:
                _bleBikeService.connectedBike = bluetoothEquipment;
                // await _bluetoothSharedPreferencesService.bluetoothCryptoBikeGoper(
                //   bikeId: bluetoothEquipment.equipment.id.id,
                // );
                // _trainingFlowData.postBikeGraph = true;
                _bleBikeService.getIndoorBikeData(services);
                break;
              case BluetoothEquipmentType.treadmill:
                _bleTreadmillService.connectedTreadmill = bluetoothEquipment;
                // await _bluetoothSharedPreferencesService
                //     .bluetoothCryptoTreadmillBLE(
                //   treadmillId: bluetoothEquipment.equipment.id.id,
                // );
                // _trainingFlowData.postTreadmillGraph = true;
                _bleTreadmillService.getTreadmillData(services);
                break;
              case BluetoothEquipmentType.frequencyMeter:
                _bleFrequencyMeterService.connectedFrequencyMeter =
                    bluetoothEquipment;
                // _trainingFlowData.postBpmGraph = true;
                // int userAge = _trainingFlowData.userAge!;
                // double userWeight = _trainingFlowData.userWeight!;
                // await _bleFrequencyMeterService.getUserData(
                //   services,
                //   userAge,
                //   userWeight,
                // );
                await _bleFrequencyMeterService
                    .getFrequencyMeterMeasurement(services);
                break;
              default:
                break;
            }
            break;
          case BluetoothDeviceState.disconnected:
            add(BluetoothEquipmentDisconnectEvent(
              bluetoothEquipment: bluetoothEquipment,
            ));
            break;
          default:
            break;
        }
      },
    );
  }

  Future<void> _disconnectEquipment(
    BluetoothEquipmentDisconnectEvent event,
    Emitter<BluetoothEquipmentState> emit,
  ) async {
    await event.bluetoothEquipment.equipment.disconnect();
    switch (event.bluetoothEquipment.equipmentType) {
      case BluetoothEquipmentType.bikeKeiser:
        if (Bluetooth.broadcastKeiser.value) {
          Bluetooth.broadcastKeiser.value = false;
          timer?.cancel();
        }
        _bleBikeService.disconnectBike();
        break;
      case BluetoothEquipmentType.bikeGoper:
        _bleBikeService.disconnectBike();
        break;
      case BluetoothEquipmentType.treadmill:
        _bleTreadmillService.disconnectTreadmill();
        break;
      case BluetoothEquipmentType.frequencyMeter:
        _bleFrequencyMeterService.disconnectFrequencyMeter();
        break;
      default:
        break;
    }
    emit(BluetoothEquipmentErrorState(
      message: 'Dispositivo desconectado',
    ));
  }

  @override
  Future<void> close() async {
    if (Bluetooth.broadcastKeiser.value) {
      Bluetooth.broadcastKeiser.value = false;
      timer?.cancel();
    }
    super.close();
  }
}
