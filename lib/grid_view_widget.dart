import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/application/services/bluetooth_equipment_service.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/equipments_cubits/bluetooth_equipments_cubit/bluetooth_equipments_cubit.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/metrics_notifiers/metrics_notifiers.dart';
import 'package:responsive_builder/responsive_builder.dart';

class GridViewWidget extends StatelessWidget {
  const GridViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      crossAxisCount: 5,
      children: [
        const _ConnectionItem(),
        ValueListenableBuilder(
          valueListenable: BleBikeMetricsNotifier.isConnected,
          builder: (context, value, child) =>
              value ? const _BikeItemWidget() : const SizedBox(),
        ),
        ValueListenableBuilder(
          valueListenable: BleTreadmillMetricsNotifier.isConnected,
          builder: (context, value, child) =>
              value ? const _TreadmillItemWidget() : const SizedBox(),
        ),
        ValueListenableBuilder(
          valueListenable: BleFrequencyMeterMetricsNotifier.isConnected,
          builder: (context, value, child) =>
              value ? const _FrequencyMeterItemWidget() : const SizedBox(),
        ),
        const SizedBox(),
      ],
    );
  }
}

class _GridViewItem extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _GridViewItem({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, si) {
        final TextStyle titleStyle = TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: si.isTablet ? 30 : 50,
          color: Colors.black,
        );

        final TextStyle textStyle = TextStyle(
          fontSize: si.isTablet ? 15 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );

        return Container(
          color: Colors.black.withOpacity(.1),
          child: Column(
            children: [
              Text(
                title,
                style: titleStyle,
              ),
              Expanded(
                child: DefaultTextStyle(
                  style: textStyle,
                  child: Column(
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ignore: unused_element
class _ConnectionItem extends StatefulWidget {
  const _ConnectionItem({super.key});

  @override
  State<_ConnectionItem> createState() => _ConnectionItemState();
}

class _ConnectionItemState extends State<_ConnectionItem> {
  late final BluetoothEquipmentsCubit _bluetoothEquipmentsCubit;

  bool isBroadcastConnection = BluetoothEquipmentService.isBroadcastConnection;

  @override
  void initState() {
    super.initState();
    _bluetoothEquipmentsCubit = context.read<BluetoothEquipmentsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    BluetoothEquipmentService.isBroadcastConnection = isBroadcastConnection;
    return _GridViewItem(
      title: 'Connection',
      children: [
        const _CustomDivider(),
        const Text('Broadcast:'),
        Switch.adaptive(
          // Don't use the ambient CupertinoThemeData to style this switch.
          applyCupertinoTheme: false,
          value: isBroadcastConnection,
          onChanged: (bool value) {
            setState(() {
              isBroadcastConnection = value;
            });
            _bluetoothEquipmentsCubit.resetScan();
          },
        ),
        const Text('Conexão Direta:'),
        Switch.adaptive(
          value: !isBroadcastConnection,
          onChanged: (bool value) {
            setState(() {
              isBroadcastConnection = !value;
            });
            _bluetoothEquipmentsCubit.resetScan();
          },
        ),
      ],
    );
  }
}

class _BikeItemWidget extends StatelessWidget {
  const _BikeItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _GridViewItem(
      title: 'Bike',
      children: [
        const _CustomDivider(),
        ValueListenableBuilder(
          valueListenable: BleBikeMetricsNotifier.isConnected,
          builder: (context, value, child) =>
              Text('Status: ${value == true ? 'Conectado' : 'Desconectado'}'),
        ),
        const _CustomDivider(),
        ValueListenableBuilder(
          valueListenable: BleBikeMetricsNotifier.cadence,
          builder: (context, value, child) => Text('Cadencia: $value'),
        ),
        ValueListenableBuilder(
          valueListenable: BleBikeMetricsNotifier.power,
          builder: (context, value, child) => Text('Potência: $value'),
        ),
        ValueListenableBuilder(
          valueListenable: BleBikeMetricsNotifier.resistance,
          builder: (context, value, child) => Text('Resistência: $value'),
        ),
        // ValueListenableBuilder(
        //   valueListenable: BleBikeMetricsNotifier.speed,
        //   builder: (context, value, child) => Text('Velociadade: $value'),
        // ),
      ],
    );
  }
}

class _TreadmillItemWidget extends StatelessWidget {
  const _TreadmillItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _GridViewItem(
      title: 'Esteira',
      children: [
        const _CustomDivider(),
        ValueListenableBuilder(
          valueListenable: BleTreadmillMetricsNotifier.isConnected,
          builder: (context, value, child) => Text(
            'Status: ${value == true ? 'Conectado' : 'Desconectado'}',
          ),
        ),
        const _CustomDivider(),
        ValueListenableBuilder(
          valueListenable: BleTreadmillMetricsNotifier.inclination,
          builder: (context, value, child) => Text('Inclinação: $value'),
        ),
        ValueListenableBuilder(
          valueListenable: BleTreadmillMetricsNotifier.power,
          builder: (context, value, child) => Text('Potência: $value'),
        ),
        ValueListenableBuilder(
          valueListenable: BleTreadmillMetricsNotifier.speed,
          builder: (context, value, child) => Text('Velocidade: $value'),
        ),
      ],
    );
  }
}

class _FrequencyMeterItemWidget extends StatelessWidget {
  const _FrequencyMeterItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _GridViewItem(
      title: 'MyBeat',
      children: [
        const _CustomDivider(),
        ValueListenableBuilder(
          valueListenable: BleFrequencyMeterMetricsNotifier.isConnected,
          builder: (context, value, child) =>
              Text('Status: ${value == true ? 'Conectado' : 'Desconectado'}'),
        ),
        const _CustomDivider(),
        ValueListenableBuilder(
          valueListenable: BleFrequencyMeterMetricsNotifier.bpmValue,
          builder: (context, value, child) => Text('BPM: $value'),
        ),
      ],
    );
  }
}

class _CustomDivider extends StatelessWidget {
  const _CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Divider(
        height: 2,
      ),
    );
  }
}
