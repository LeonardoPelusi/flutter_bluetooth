import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_enum.dart';

class BluetoothEquipmentModel extends Equatable {
  final String id;
  final BluetoothDevice equipment;
  final BluetothEquipmentType equipmentType;

  BluetoothEquipmentModel({
    required this.id,
    required this.equipment,
    this.equipmentType = BluetothEquipmentType.undefined,
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
