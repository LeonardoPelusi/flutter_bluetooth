import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/extension.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';

part 'bluetooth_equipment_event.dart';
part 'bluetooth_equipment_state.dart';

class BluetoothEquipmentBloc {
    // extends Bloc<BluetoothEquipmentEvent, BluetoothEquipmentState> {
  // BluetoothEquipmentBloc(
  //     //!TODO implementar shared preferences
  //     // this._bluetoothSharedPreferencesService,
  //     // this._trainingFlowData,
  //     )
  //     : super(BluetoothEquipmentInitialState()) {
  //   on<BluetoothEquipmentConnectEvent>(_connectEquipment);
  //   on<BluetoothEquipmentConnectValidatorEvent>(_connectValidator);
  //   on<BluetoothEquipmentBroadcastConnectEvent>(_broadcastConnect);
  //   on<BluetoothEquipmentDirectConnectEvent>(_directConnect);
  //   on<BluetoothEquipmentTrackEvent>(_trackEquipmentState);
  //   on<BluetoothEquipmentDisconnectEvent>(_disconnectEquipment);
  // }

  // // Services
  // // final BluetoothSharedPreferencesService _bluetoothSharedPreferencesService;
  // // final TrainingFlowData _trainingFlowData;

  // // Bluetooth Services
  // final BluetoothBikeService _bleBikeService = BluetoothBikeService.instance;
  // final BluetoothTreadmillService _bleTreadmillService =
  //     BluetoothTreadmillService.instance;
  // final BluetoothFrequencyMeterService _bleFrequencyMeterService =
  //     BluetoothFrequencyMeterService.instance;

  // // Variables
  // final Duration _directConnectionTimeoutDuration = const Duration(seconds: 10);

  // Timer? _broadcastResetTimer;
  // final Duration _broadcastTimerResetDuration = const Duration(minutes: 25);

  // // Streams
  // StreamSubscription<List<ScanResult>>? _broadcastSubscription;

  // Future<void> _connectEquipment(
  //   BluetoothEquipmentConnectEvent event,
  //   Emitter<BluetoothEquipmentState> emit,
  // ) async {
  //   final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;

  //   emit(BluetoothEquipmentConnectingState(
  //     connectingEquipment: bluetoothEquipment,
  //   ));

  //   add(BluetoothEquipmentConnectValidatorEvent(
  //     bluetoothEquipment: bluetoothEquipment,
  //   ));

  //   // !TODO implementar lógica broadcast
  //   if (BluetoothEquipmentService.isBroadcastConnection) {
  //     add(BluetoothEquipmentBroadcastConnectEvent(
  //       bluetoothEquipment: bluetoothEquipment,
  //     ));
  //   } else {
  //     add(BluetoothEquipmentDirectConnectEvent(
  //       bluetoothEquipment: bluetoothEquipment,
  //     ));
  //   }
  // }

  // Future<void> _connectValidator(
  //   BluetoothEquipmentConnectValidatorEvent event,
  //   Emitter<BluetoothEquipmentState> emit,
  // ) async {
  //   switch (event.bluetoothEquipment.equipmentType) {
  //     case BluetoothEquipmentType.bikeGoper ||
  //           BluetoothEquipmentType.bikeKeiser:
  //       if (_bleBikeService.connectedBike != null) {
  //         _bleBikeService.cleanBikeData();
  //         await event.bluetoothEquipment.equipment.disconnect();
  //         if (FlutterBluePlus.isScanningNow) {
  //           FlutterBluePlus.stopScan();
  //         }
  //       }
  //       break;
  //     case BluetoothEquipmentType.treadmill:
  //       if (_bleTreadmillService.connectedTreadmill != null) {
  //         await event.bluetoothEquipment.equipment.disconnect();
  //         _bleTreadmillService.cleanTreadmillData();
  //       }
  //       break;
  //     case BluetoothEquipmentType.frequencyMeter:
  //       if (_bleFrequencyMeterService.connectedFrequencyMeter != null) {
  //         await event.bluetoothEquipment.equipment.disconnect();
  //         _bleFrequencyMeterService.clearUserData();
  //         _bleFrequencyMeterService.cleanFequencyMeterData();
  //       }
  //       break;
  //     default:
  //       break;
  //   }
  // }

  // Future<void> _broadcastConnect(
  //   BluetoothEquipmentBroadcastConnectEvent event,
  //   Emitter<BluetoothEquipmentState> emit,
  // ) async {
  //   final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;

  //   emit(BluetoothEquipmentConnectedState(
  //     connectedEquipment: bluetoothEquipment,
  //   ));

  //   _bleBikeService.updateConnectedBike(bluetoothEquipment);

  //   // _bluetoothSharedPreferencesService.bluetoothCryptoBikeKeiser(
  //   //   bikeKeiserId: bluetoothEquipment.equipment.id.id,
  //   // );
  //   // _trainingFlowData.postBikeGraph = true;

  //   await Future.delayed(const Duration(milliseconds: 200));

  //   _broadcastSubscription =
  //       FlutterBluePlus.onScanResults.listen((scanResults) {
  //     if (scanResults.isNotEmpty) {
  //       for (ScanResult scanResult in scanResults) {
  //         if (scanResult.device.remoteId ==
  //             bluetoothEquipment.equipment.remoteId) {
  //           final Uint8List manufacturerData = scanResult
  //               .advertisementData.manufacturerData.values.first
  //               .asUint8List();

  //           switch (event.bluetoothEquipment.equipmentType) {
  //             case BluetoothEquipmentType.bikeKeiser:
  //               _bleBikeService.getBroadcastBikeKeiserData(manufacturerData);
  //               break;
  //             case BluetoothEquipmentType.bikeGoper:
  //               _bleBikeService.getBroadcastBikeGoperData(manufacturerData);
  //               break;

  //             default:
  //               break;
  //           }
  //         }
  //       }
  //     }
  //   });

  //   await FlutterBluePlus.startScan();

  //   _broadcastResetTimer?.cancel();
  //   // é necessário reiniciar o broadcast depois de 30min
  //   _broadcastResetTimer = Timer(
  //     _broadcastTimerResetDuration,
  //     () {
  //       add(
  //         BluetoothEquipmentBroadcastConnectEvent(
  //             bluetoothEquipment: bluetoothEquipment),
  //       );
  //     },
  //   );
  // }

  // Future<void> _directConnect(
  //   BluetoothEquipmentDirectConnectEvent event,
  //   Emitter<BluetoothEquipmentState> emit,
  // ) async {
  //   final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;

  //   try {
  //     await bluetoothEquipment.equipment.connect(
  //       timeout: _directConnectionTimeoutDuration,
  //     );
  //     add(BluetoothEquipmentTrackEvent(
  //       bluetoothEquipment: bluetoothEquipment,
  //     ));
  //   } catch (e) {
  //     if (e == 'already_connected') {
  //       emit(BluetoothEquipmentErrorState(
  //         message: 'Dispositivo já conectado',
  //       ));
  //     } else {
  //       if (event.retries <= 2) {
  //         add(BluetoothEquipmentDirectConnectEvent(
  //           bluetoothEquipment: bluetoothEquipment,
  //           retries: event.retries + 1,
  //         ));
  //       } else {
  //         emit(BluetoothEquipmentErrorState(
  //           message: 'Não foi possivel realizar a conexão',
  //         ));
  //       }
  //     }
  //   }
  // }

  // void _trackEquipmentState(
  //   BluetoothEquipmentTrackEvent event,
  //   Emitter<BluetoothEquipmentState> emit,
  // ) async {
  //   final BluetoothEquipmentModel bluetoothEquipment = event.bluetoothEquipment;

  //   await emit.onEach(
  //     bluetoothEquipment.equipment.connectionState,
  //     onData: (state) async {
  //       switch (state) {
  //         case BluetoothConnectionState.connected:
  //           emit(BluetoothEquipmentConnectedState(
  //             connectedEquipment: bluetoothEquipment,
  //           ));
  //           List<BluetoothService> services =
  //               await bluetoothEquipment.equipment.discoverServices();
  //           switch (bluetoothEquipment.equipmentType) {
  //             case BluetoothEquipmentType.bikeGoper:
  //               // _trainingFlowData.postBikeGraph = true;
  //               // await _bluetoothSharedPreferencesService.bluetoothCryptoBikeGoper(
  //               //   bikeId: bluetoothEquipment.equipment.id.id,
  //               // );
  //               _bleBikeService.updateConnectedBike(bluetoothEquipment);
  //               await _bleBikeService.getIndoorBikeData(services);
  //               break;
  //             case BluetoothEquipmentType.treadmill:
  //               // _trainingFlowData.postTreadmillGraph = true;

  //               // await _bluetoothSharedPreferencesService
  //               //     .bluetoothCryptoTreadmillBLE(
  //               //   treadmillId: bluetoothEquipment.equipment.id.id,
  //               // );
  //               _bleTreadmillService
  //                   .updateConnectedTreadmill(bluetoothEquipment);
  //               await _bleTreadmillService.getTreadmillData(services);
  //               break;
  //             case BluetoothEquipmentType.frequencyMeter:
  //               // _trainingFlowData.postBpmGraph = true;

  //               // int userAge = _trainingFlowData.userAge!;
  //               // double userWeight = _trainingFlowData.userWeight!;
  //               // await _bleFrequencyMeterService.getUserData(
  //               //   services,
  //               //   userAge,
  //               //   userWeight,
  //               // );

  //               _bleFrequencyMeterService
  //                   .updateConnectedFrequencyMeter(bluetoothEquipment);
  //               await _bleFrequencyMeterService
  //                   .getFrequencyMeterMeasurement(services);
  //               break;
  //             default:
  //               break;
  //           }
  //           break;
  //         case BluetoothConnectionState.disconnected:
  //           add(BluetoothEquipmentDisconnectEvent(
  //             bluetoothEquipment: bluetoothEquipment,
  //           ));
  //           break;
  //         default:
  //           break;
  //       }
  //     },
  //   );
  // }

  // Future<void> _disconnectEquipment(
  //   BluetoothEquipmentDisconnectEvent event,
  //   Emitter<BluetoothEquipmentState> emit,
  // ) async {
  //   await event.bluetoothEquipment.equipment.disconnect();
  //   switch (event.bluetoothEquipment.equipmentType) {
  //     case BluetoothEquipmentType.bikeKeiser ||
  //           BluetoothEquipmentType.bikeGoper:
  //       if (BluetoothEquipmentService.isBroadcastConnection) {
  //         _broadcastResetTimer?.cancel();
  //         _broadcastResetTimer = null;
  //         _broadcastSubscription?.cancel();
  //         _broadcastSubscription = null;
  //       }
  //       _bleBikeService.cleanBikeData();
  //       break;
  //     case BluetoothEquipmentType.treadmill:
  //       _bleTreadmillService.cleanTreadmillData();
  //       break;
  //     case BluetoothEquipmentType.frequencyMeter:
  //       _bleFrequencyMeterService.clearUserData();
  //       _bleFrequencyMeterService.cleanFequencyMeterData();
  //       break;
  //     default:
  //       break;
  //   }
  //   emit(BluetoothEquipmentErrorState(
  //     message: 'Dispositivo desconectado',
  //   ));
  // }
}
