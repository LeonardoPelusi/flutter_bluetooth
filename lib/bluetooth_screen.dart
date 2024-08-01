import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth/grid_view_widget.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_connect_ftms_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipments_cubit/bluetooth_equipments_cubit.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothEquipmentsCubit>(
          create: (context) => BluetoothEquipmentsCubitImpl(
            BluetoothConnectFTMS.all,
          ),
        ),
      ],
      child: const _BluetoothScreen(),
    );
  }
}

class _BluetoothScreen extends StatefulWidget {
  const _BluetoothScreen({super.key});

  @override
  State<_BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<_BluetoothScreen> {
  late final BluetoothEquipmentsCubit _bluetoothEquipmentsCubit;

  @override
  void initState() {
    super.initState();
    _bluetoothEquipmentsCubit = context.read<BluetoothEquipmentsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      body: BlocBuilder<BluetoothEquipmentsCubit, BluetoothEquipmentsState>(
          bloc: _bluetoothEquipmentsCubit,
          buildWhen: (previous, current) =>
              previous.bluetoothEquipments != current.bluetoothEquipments,
          builder: (context, state) {
            if (state.bluetoothEquipments.isEmpty) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    _bluetoothEquipmentsCubit.startScan();
                  },
                  child: const Text('Start Scan'),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  flex: 14,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.025,
                    ),
                    itemCount: state.bluetoothEquipments.length,
                    itemBuilder: (ctx, index) {
                      final bluetoothEquipment =
                          state.bluetoothEquipments[index];

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.005,
                        ),
                        child: BluetoothItemWidget(
                          bluetoothEquipment: bluetoothEquipment,
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
                const Expanded(
                  flex: 12,
                  child: GridViewWidget(),
                ),
              ],
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
  late final BluetoothEquipmentsCubit _bluetoothEquipmentsCubit;

  @override
  void initState() {
    super.initState();
    _bluetoothEquipmentsCubit = context.read<BluetoothEquipmentsCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothEquipmentsCubit, BluetoothEquipmentsState>(
        builder: (context, state) {
      final bool connected =
          state.connectedEquipments.contains(widget.bluetoothEquipment);

      return GestureDetector(
        onTap: () => connected
            ? _bluetoothEquipmentsCubit
                .disconnectDevice(widget.bluetoothEquipment)
            : _bluetoothEquipmentsCubit
                .connectDevice(widget.bluetoothEquipment),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(
              color: Colors.black,
            ),
          ),
          elevation: 16,
          shadowColor: Colors.black,
          child: ListTile(
            title: Text(
                '${widget.bluetoothEquipment.id} - ${widget.bluetoothEquipment.equipment.name}'),
            subtitle: Text(widget.bluetoothEquipment.equipmentType.name),
            trailing: connected
                ? const Icon(Icons.close)
                : const Text(
                    'Conectar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blue,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
