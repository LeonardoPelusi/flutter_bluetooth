import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';

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
      body: GridView.count(
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        crossAxisCount: (widget.bluetoothEquipment.equipmentType ==
                    BluetoothEquipmentType.bikeGoper ||
                widget.bluetoothEquipment.equipmentType ==
                    BluetoothEquipmentType.bikeKeiser)
            ? 4
            : widget.bluetoothEquipment.equipmentType ==
                    BluetoothEquipmentType.treadmill
                ? 2
                : 1,
        children: [..._bikeItems()],
      ),
    );
  }

  List<Widget> _bikeItems() {
    final bleBikeService = BluetoothEquipmentService.instance.bikeService;
    return [
      ValueListenableBuilder(
        valueListenable: bleBikeService.instaCadence,
        builder: (context, value, child) => _GridViewItem(
          title: 'Cadencia',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: bleBikeService.instaPower,
        builder: (context, value, child) => _GridViewItem(
          title: 'Potência',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: bleBikeService.resistanceLevel,
        builder: (context, value, child) => _GridViewItem(
          title: 'Resistência',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: bleBikeService.speed,
        builder: (context, value, child) => _GridViewItem(
          title: 'Velociadade',
          value: value.toString(),
        ),
      ),
    ];
  }
}

class _GridViewItem extends StatelessWidget {
  final String title;
  final String value;
  const _GridViewItem({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(.1),
      child: Column(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 50,
              ),
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
               style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
