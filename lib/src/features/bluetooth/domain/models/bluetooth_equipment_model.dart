import 'package:equatable/equatable.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothEquipmentModel extends Equatable {
  final String id;
  final DiscoveredDevice equipment;
  final BluetoothEquipmentType equipmentType;
  final BluetoothCommunicationType communicationType;

  const BluetoothEquipmentModel({
    required this.id,
    required this.equipment,
    required this.equipmentType,
    required this.communicationType,
  });

  @override
  List<Object?> get props {
    return [
      id,
      equipment,
      equipmentType,
      communicationType,
    ];
  }
}
