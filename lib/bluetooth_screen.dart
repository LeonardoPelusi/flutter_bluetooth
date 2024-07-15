import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipment_bloc/bluetooth_equipment_bloc.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipments_bloc/bluetooth_equipments_bloc.dart';

class BluetoothScreenState extends StatelessWidget {
  const BluetoothScreenState({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BluetoothEquipmentsBloc>(
      create: (_) => BluetoothEquipmentsBloc(),
      child: const Placeholder(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  late final BluetoothEquipmentsBloc _bluetoothEquipmentsBloc;

  @override
  void initState() {
    super.initState();
    _bluetoothEquipmentsBloc = context.read<BluetoothEquipmentsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth'),
      ),
      body: BlocBuilder<BluetoothEquipmentsBloc, BluetoothEquipmentsState>(
          bloc: _bluetoothEquipmentsBloc,
          builder: (context, state) {
            return ListView.builder(
              itemCount: state.bluetoothEquipments.length,
              itemBuilder: (ctx, index) {
                final _bluetoothEquipment = state.bluetoothEquipments[index];

                return BlocProvider(
                  create: (context) => BluetoothEquipmentBloc(),
                  child: BluetoothItemWidget(
                    bluetoothEquipment: _bluetoothEquipment,
                  ),
                );
              },
            );
          }),
    );
  }
}

class BluetoothItemWidget extends StatefulWidget {
  final BluetoothEquipmentModel bluetoothEquipment;
  const BluetoothItemWidget({
    required this.bluetoothEquipment,
    super.key,
  });

  @override
  State<BluetoothItemWidget> createState() => _BluetoothItemWidgetState();
}

class _BluetoothItemWidgetState extends State<BluetoothItemWidget> {
  late final BluetoothEquipmentBloc _bluetoothEquipmentBloc;

  @override
  void initState() {
    super.initState();
    _bluetoothEquipmentBloc = context.read<BluetoothEquipmentBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BluetoothEquipmentBloc, BluetoothEquipmentState>(
        listener: (context, state) {},
        builder: (context, state) {
          return ListTile(
            title: Text(widget.bluetoothEquipment.equipment.name),
            trailing: state is BluetoothEquipmentConnectingState
                ? const CircularProgressIndicator()
                : TextButton(
                    onPressed: () {},
                    child: Text('Conectar'),
                  ),
          );
        });
  }
}
