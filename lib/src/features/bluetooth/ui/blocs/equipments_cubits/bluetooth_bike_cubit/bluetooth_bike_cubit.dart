import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bike/bike_goper.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/equipments/bike/bike_keiser.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/equipments_cubits/bluetooth_equipments_cubit/bluetooth_equipments_cubit.dart';
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
  ) {
    _bluetoothEquipmentsStream =
        _bluetoothEquipmentsCubit.stream.listen((bluetoothEquipmentsState) {
      if (bluetoothEquipmentsState.bluetoothEquipments.isEmpty) return;
      if (bluetoothEquipmentsState.bluetoothEquipments.last.equipmentType !=
          BluetoothEquipmentType.bikeGoper) return;
      if (bluetoothEquipmentsState.bluetoothEquipments.last.equipmentType !=
          BluetoothEquipmentType.bikeKeiser) return;
    });
  }

  // Cubits
  final BluetoothEquipmentsCubit _bluetoothEquipmentsCubit;
  StreamSubscription? _bluetoothEquipmentsStream;

  // Services
  final BikeKeiser _bikeKeiserService = BikeKeiser();
  final BikeGoper _bikeGoperService = BikeGoper();

  // Streams
  StreamSubscription<BluetoothEquipmentModel>? _bikeBroadcastStream;
  StreamSubscription<ConnectionStateUpdate>? _bikeStream;

  @override
  void connect(BluetoothEquipmentModel equipment) async {
    emit(BluetoothBikeConnecting(
      equipment: equipment,
    ));

    _bikeBroadcastStream?.cancel();
    _bikeStream?.cancel();

    if (equipment.communicationType == BluetoothCommunicationType.broadcast) {
      _listenToBroadcast(equipment);
    } else {
      _bikeStream = _bluetoothEquipmentsCubit
          .connectToEquipment(equipment)
          .listen(
              (state) => _listenToEquipmentState(state, equipment: equipment));
    }
  }

  // =============== BROADCAST ===============

  void _listenToBroadcast(BluetoothEquipmentModel equipment) {
    emit(BluetoothBikeConnected(
      equipment: equipment,
    ));
    _bikeBroadcastStream = _bluetoothEquipmentsCubit.equipmentsStream
        .listen(_onEquipmentDiscovered);
  }

  void _onEquipmentDiscovered(BluetoothEquipmentModel equipment) {
    if (state is BluetoothBikeConnected) {
      final state = this.state as BluetoothBikeConnected;
      if (state.equipment.equipment.id == equipment.equipment.id) {
        _listenToBroadcastMetrics(equipment);
      }
    }
  }

  void _listenToBroadcastMetrics(BluetoothEquipmentModel equipment) {
    final Uint8List manufacturerData = equipment.equipment.manufacturerData;

    switch (equipment.equipmentType) {
      case BluetoothEquipmentType.bikeKeiser:
        _bikeKeiserService.getDataFromManufacturerData(manufacturerData);
        break;
      case BluetoothEquipmentType.bikeGoper:
        _bikeGoperService.getDataFromManufacturerData(manufacturerData);
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
        emit(BluetoothBikeConnecting(
          equipment: equipment,
        ));
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
      disconnect();
      _listenToBroadcastMetrics(equipment);

      // switch (equipmentState.failure?.code) {
      //   case ConnectionError.failedToConnect:
      //     emit(const BluetoothBikeError(
      //       message: 'Falha ao se conectar com a bike',
      //     ));

      //     break;
      //   case ConnectionError.unknown:
      //     _bluetoothEquipmentsCubit
      //         .emit(_bluetoothEquipmentsCubit.state.copyWith(
      //       bluetoothEquipments: _bluetoothEquipmentsCubit
      //           .state.bluetoothEquipments
      //           .where((element) => element.equipment.id != equipment.id)
      //           .toList(),
      //     ));
      //     emit(const BluetoothBikeError(
      //       message: 'Erro ao se conectar com a bike',
      //     ));
      //     break;
      //   default:
      //     break;
      // }
    }
  }

  void _listenToDeviceServices(BluetoothEquipmentModel equipment) async {
    final List<Service> services =
        await BluetoothEquipmentService.getServicesList(equipment);
    await _bikeGoperService.getDataFromServices(services);
  }

  // ========== END DIRECT CONNECT ==========

  @override
  void disconnect() {
    _clearData();
    emit(BluetoothBikeInitial());
  }

  void _clearData() {
    _bikeKeiserService.cleanData();
    _bikeGoperService.cleanData();
    _bikeBroadcastStream?.cancel();
    _bikeBroadcastStream = null;
    _bikeStream?.cancel();
    _bikeStream = null;
  }

  @override
  Future<void> close() async {
    _bluetoothEquipmentsStream?.cancel();
    _bluetoothEquipmentsStream = null;
    _clearData();
    super.close();
  }
}
