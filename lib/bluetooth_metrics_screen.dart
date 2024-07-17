import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_equipment_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';

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
  late final bool _isBike;
  late final bool _isTreadmill;

  @override
  void initState() {
    super.initState();
    _isBike = widget.bluetoothEquipment.equipmentType ==
            BluetoothEquipmentType.bikeGoper ||
        widget.bluetoothEquipment.equipmentType ==
            BluetoothEquipmentType.bikeKeiser;

    _isTreadmill = widget.bluetoothEquipment.equipmentType ==
        BluetoothEquipmentType.treadmill;
  }

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
        crossAxisCount: _isBike
            ? 4
            : widget.bluetoothEquipment.equipmentType ==
                    BluetoothEquipmentType.treadmill
                ? 3
                : 1,
        children: _isBike
            ? _bikeItems()
            : _isTreadmill
                ? _treadmillItems()
                : _frequenceMeterItems(),
      ),
    );
  }

  List<Widget> _bikeItems() {
    return [
      ValueListenableBuilder(
        valueListenable: BleBikeMetricsNotifier.instaCadence,
        builder: (context, value, child) => _GridViewItem(
          title: 'Cadencia',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: BleBikeMetricsNotifier.instaPower,
        builder: (context, value, child) => _GridViewItem(
          title: 'Potência',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: BleBikeMetricsNotifier.resistanceLevel,
        builder: (context, value, child) => _GridViewItem(
          title: 'Resistência',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: BleBikeMetricsNotifier.speed,
        builder: (context, value, child) => _GridViewItem(
          title: 'Velociadade',
          value: value.toString(),
        ),
      ),
    ];
  }

  List<Widget> _treadmillItems() {
    return [
      ValueListenableBuilder(
        valueListenable: BleTreadmillMetricsNotifier.inclination,
        builder: (context, value, child) => _GridViewItem(
          title: 'Inclinação',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: BleTreadmillMetricsNotifier.instaPower,
        builder: (context, value, child) => _GridViewItem(
          title: 'Potência',
          value: value.toString(),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: BleTreadmillMetricsNotifier.speed,
        builder: (context, value, child) => _GridViewItem(
          title: 'Velocidade',
          value: value.toString(),
        ),
      ),
    ];
  }

  List<Widget> _frequenceMeterItems() {
    return [
      ValueListenableBuilder(
        valueListenable: BleFrequencyMeterMetricsNotifier.bpmValue,
        builder: (context, value, child) => _GridViewItem(
          title: 'BPM',
          value: value.toString(),
        ),
      ),
    ];
  }
}

class _BikeItens extends StatelessWidget {
  const _BikeItens({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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
                fontSize: 40,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
