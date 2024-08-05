import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments_services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipments_cubit/bluetooth_equipments_cubit.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

part 'bluetooth_bike_state.dart';

abstract class BluetoothBikeCubit extends Cubit<BluetoothBikeState> {
  BluetoothBikeCubit() : super(BluetoothBikeInitial());

  void connect(BluetoothEquipmentModel equipment);
  void disconnect();
}

class BluetoothBikeCubitImpl extends BluetoothBikeCubit {
  BluetoothBikeCubitImpl(
    this._bluetoothEquipmentsCubit,
  );

  // Cubits
  final BluetoothEquipmentsCubit _bluetoothEquipmentsCubit;

  // Services
  final BluetoothEquipmentService _equipmentService =
      BluetoothEquipmentService.instance;
  final BluetoothBikeService _bikeService = BluetoothBikeService.instance;

  // Streams
  StreamSubscription<BluetoothEquipmentModel>? _bikeBroadcastStream;
  StreamSubscription<ConnectionStateUpdate>? _bikeStream;

  @override
  void connect(BluetoothEquipmentModel equipment) async {
    emit(BluetoothBikeConnecting());

    _bikeBroadcastStream?.cancel();
    _bikeStream?.cancel();

    if (equipment.connectionType == BluetoothConnectionType.broadcast) {
      _bikeService.updateConnectedBike(equipment);
      _bikeBroadcastStream = _bluetoothEquipmentsCubit.equipmentsStream
          .listen(_onEquipmentDiscovered);
      emit(BluetoothBikeConnected(
        equipment: equipment,
      ));
    } else {
      _bikeStream = _bluetoothEquipmentsCubit
          .connectToEquipment(equipment)
          .listen(
              (state) => _listenToEquipmentState(state, equipment: equipment));
    }
  }

  // =============== BROADCAST ===============

  void _onEquipmentDiscovered(BluetoothEquipmentModel equipment) {
    _listenToBroadcastMetrics(equipment);
  }

  void _listenToBroadcastMetrics(BluetoothEquipmentModel equipment) {
    final Uint8List manufacturerData = equipment.equipment.manufacturerData;

    switch (equipment.equipmentType) {
      case BluetoothEquipmentType.bikeKeiser:
        _bikeService.getBroadcastBikeKeiserData(manufacturerData);
        break;
      case BluetoothEquipmentType.bikeGoper:
        _bikeService.getBroadcastBikeGoperData(manufacturerData);
        break;
      default:
        break;
    }
  }

  // =========== END BROADCAST ==============

  // =========== DIRECT CONNECT =============

  void _listenToEquipmentState(
    ConnectionStateUpdate equipmentState, {
    required BluetoothEquipmentModel equipment,
  }) {
    switch (equipmentState.connectionState) {
      case DeviceConnectionState.connecting:
        emit(BluetoothBikeConnecting());
        break;
      case DeviceConnectionState.connected:
        _listenToDeviceServices(equipment);

        emit(BluetoothBikeConnected(
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
          emit(const BluetoothBikeError(
            message: 'Falha ao se conectar com o equipamento',
          ));

          break;
        case ConnectionError.unknown:
          emit(const BluetoothBikeError(
            message: 'Erro ao se conectar com o equipamento',
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
        await _equipmentService.getServicesList(equipment);
    _bikeService.updateConnectedBike(equipment);
    await _bikeService.getIndoorBikeData(services);
  }

  // ========== END DIRECT CONNECT ==========

  @override
  void disconnect() {
    _clearData();
    emit(BluetoothBikeInitial());
  }

  void _clearData() {
    _bikeService.cleanBikeData();
    _bikeBroadcastStream?.cancel();
    _bikeBroadcastStream = null;
    _bikeStream?.cancel();
    _bikeStream = null;
  }

  @override
  Future<void> close() async {
    _clearData();
    super.close();
  }
}
