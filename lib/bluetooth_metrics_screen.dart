import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_model.dart';

class BluetoothMetricsScreen extends StatefulWidget {
  final BluetoothEquipmentModel bluetoothEquipment;
  const BluetoothMetricsScreen({
    required this.bluetoothEquipment,
    super.key,
  });

  @override
  State<BluetoothMetricsScreen> createState() => _BluetoothMetricsScreenState();
}

class _BluetoothMetricsScreenState extends State<BluetoothMetricsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.bluetoothEquipment.id} - ${widget.bluetoothEquipment.equipment.name}'),
      ),
    );
  }
}
