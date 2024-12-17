import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/treadmill/treadmill.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/equipments_cubits/bluetooth_equipments_cubit/bluetooth_equipments_cubit.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part 'bluetooth_treadmill_state.dart';

abstract class BluetoothTreadmillCubit extends Cubit<BluetoothTreadmillState> {
  BluetoothTreadmillCubit() : super(BluetoothTreadmillInitial());

  void connect(BluetoothEquipmentModel equipment);
  void disconnect();
}

class BluetoothTreadmillCubitImpl extends BluetoothTreadmillCubit {
  BluetoothTreadmillCubitImpl(
    this._bluetoothEquipmentsCubit,
  );

  // Cubits
  final BluetoothEquipmentsCubit _bluetoothEquipmentsCubit;

  // Services
  final Treadmill _treadmillService = Treadmill();

  // Streams
  StreamSubscription<BluetoothEquipmentModel>? _treadmillBroadcastStream;
  StreamSubscription<ConnectionStateUpdate>? _treadmillStream;

  @override
  void connect(BluetoothEquipmentModel equipment) async {
    emit(BluetoothTreadmillConnecting(
      equipment: equipment,
    ));

    _treadmillBroadcastStream?.cancel();
    _treadmillStream?.cancel();

    _treadmillStream = _bluetoothEquipmentsCubit
        .connectToEquipment(equipment)
        .listen(
            (state) => _listenToEquipmentState(state, equipment: equipment));
  }

  // =========== DIRECT CONNECT =============

  void _listenToEquipmentState(
    ConnectionStateUpdate equipmentState, {
    required BluetoothEquipmentModel equipment,
  }) {
    switch (equipmentState.connectionState) {
      case DeviceConnectionState.connecting:
        emit(BluetoothTreadmillConnecting(
          equipment: equipment,
        ));
        break;
      case DeviceConnectionState.connected:
        _listenToDeviceServices(equipment);

        emit(BluetoothTreadmillConnected(
          equipment: equipment,
        ));

        break;
      case DeviceConnectionState.disconnecting ||
            DeviceConnectionState.disconnected:
        disconnect();
        break;
      default:
        break;
    }

    if (equipmentState.failure != null) {
      switch (equipmentState.failure?.code) {
        case ConnectionError.failedToConnect:
          emit(const BluetoothTreadmillError(
            message: 'Falha ao se conectar com a esteira',
          ));

          break;
        case ConnectionError.unknown:
          emit(const BluetoothTreadmillError(
            message: 'Erro ao se conectar com a esteira',
          ));
          break;
        default:
          break;
      }
      disconnect();
    }
  }

  void _listenToDeviceServices(BluetoothEquipmentModel equipment) async {
    final List<Service> services =
        await BluetoothEquipmentService.getServicesList(equipment);
    await _treadmillService.getDataFromServices(services);
  }

  // ========== END DIRECT CONNECT ==========

  @override
  void disconnect() {
    _clearData();
    emit(BluetoothTreadmillInitial());
  }

  void _clearData() {
    _treadmillService.cleanData();
    _treadmillBroadcastStream?.cancel();
    _treadmillBroadcastStream = null;
    _treadmillStream?.cancel();
    _treadmillStream = null;
  }

  @override
  Future<void> close() async {
    _clearData();
    super.close();
  }
}
