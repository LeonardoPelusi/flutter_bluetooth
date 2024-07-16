import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';

class BluetoothEquipmentModel extends Equatable {
  final String id;
  final BluetoothDevice equipment;
  final BluetoothEquipmentType equipmentType;
  final Uint8List manufacturerData;

  const BluetoothEquipmentModel({
    required this.id,
    required this.equipment,
    required this.equipmentType,
    required this.manufacturerData,
  });

  @override
  List<Object?> get props {
    return [
      id,
      equipment,
      equipmentType,
      manufacturerData,
    ];
  }
}
