import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/equipments_cubits/bluetooth_bike_cubit/bluetooth_bike_cubit.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/equipments_cubits/bluetooth_equipments_cubit/bluetooth_equipments_cubit.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/equipments_cubits/bluetooth_frequency_meter_cubit/bluetooth_frequency_meter_cubit.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/equipments_cubits/bluetooth_treadmill_cubit/bluetooth_treadmill_cubit.dart';

part 'bluetooth_automatic_connect_state.dart';

abstract class BluetoothAutomaticConnectCubit
    extends Cubit<BluetoothAutomaticConnectState> {
  BluetoothAutomaticConnectCubit() : super(BluetoothAutomaticConnectInitial());
}

class BluetoothAutomaticConnectCubitImpl
    extends BluetoothAutomaticConnectCubit {
  BluetoothAutomaticConnectCubitImpl(
    this._bluetoothEquipmentsCubit,
    this._bluetoothBikeCubit,
    this._bluetoothTreadmillCubit,
    this._bluetoothFrequencyMeterCubit,
  );

  // Cubits
  final BluetoothEquipmentsCubit _bluetoothEquipmentsCubit;
  final BluetoothBikeCubit _bluetoothBikeCubit;
  final BluetoothTreadmillCubit _bluetoothTreadmillCubit;
  final BluetoothFrequencyMeterCubit _bluetoothFrequencyMeterCubit;

  // Timers
  final Duration _connectValidationDuration = const Duration(seconds: 5);

  // Getters
  List<BluetoothEquipmentModel> get bluetoothEquipments =>
      _bluetoothEquipmentsCubit.state.bluetoothEquipments;

  List<BluetoothEquipmentModel> get bluetoothBikes => bluetoothEquipments
      .where((equip) =>
          (equip.equipmentType == BluetoothEquipmentType.bikeKeiser ||
              equip.equipmentType == BluetoothEquipmentType.bikeGoper))
      .toList();

  List<BluetoothEquipmentModel> get bluetoothTreadmills => bluetoothEquipments
      .where(
          (equip) => (equip.equipmentType == BluetoothEquipmentType.treadmill))
      .toList();

  List<BluetoothEquipmentModel> get bluetoothFrequencyMeters =>
      bluetoothEquipments
          .where((equip) =>
              (equip.equipmentType == BluetoothEquipmentType.frequencyMeter))
          .toList();

  Future<void> startAutomaticConnectValidation() async {
    await Future.delayed(_connectValidationDuration);

    if (bluetoothEquipments.isEmpty) {
      _connectWithFirstEquipment();
    } else {
      if (bluetoothBikes.length == 1) {
        _bluetoothBikeCubit.connect(bluetoothBikes.first);
      } else if (bluetoothTreadmills.length == 1) {
        _bluetoothTreadmillCubit.connect(bluetoothTreadmills.first);
      }

      if (bluetoothFrequencyMeters.length == 1) {
        _bluetoothFrequencyMeterCubit.connect(bluetoothFrequencyMeters.first);
      }
    }
  }

  void _connectWithFirstEquipment() {}
}
