import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothEquipmentModel extends Equatable {
  final String id;
  final DiscoveredDevice equipment;
  final BluetoothEquipmentType equipmentType;

  const BluetoothEquipmentModel({
    required this.id,
    required this.equipment,
    required this.equipmentType,
  });

  @override
  List<Object?> get props {
    return [
      id,
      equipment,
      equipmentType,
    ];
  }
}
