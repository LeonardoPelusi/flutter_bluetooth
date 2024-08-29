import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';

extension ListBluetoothEquipmentModelExtension
    on List<BluetoothEquipmentModel> {
  bool hasEquipment(BluetoothEquipmentModel equipment) {
    for (BluetoothEquipmentModel equip in this) {
      if (equip.id == equipment.id) return true;
    }
    return false;
  }
}
