import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth/grid_view_widget.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_enums.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_bike_cubit/bluetooth_bike_cubit.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipments_cubit/bluetooth_equipments_cubit.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_treadmill_cubit/bluetooth_treadmill_cubit.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothEquipmentsCubit>(
          create: (_) => BluetoothEquipmentsCubitImpl(
            BluetoothConnectFTMS.all,
          ),
        ),
        BlocProvider<BluetoothBikeCubit>(
          create: (context) => BluetoothBikeCubitImpl(
            context.read<BluetoothEquipmentsCubit>(),
          ),
        ),
        BlocProvider<BluetoothTreadmillCubit>(
          create: (context) => BluetoothTreadmillCubitImpl(
            context.read<BluetoothEquipmentsCubit>(),
          ),
        )
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
                        child: bluetoothEquipment.equipmentType ==
                                    BluetoothEquipmentType.bikeGoper ||
                                bluetoothEquipment.equipmentType ==
                                    BluetoothEquipmentType.bikeKeiser
                            ? _BikeItem(bluetoothEquipment: bluetoothEquipment)
                            : bluetoothEquipment.equipmentType ==
                                    BluetoothEquipmentType.treadmill
                                ? _TreadmillItem(
                                    bluetoothEquipment: bluetoothEquipment)
                                : BluetoothItemWidget(
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

class _BikeItem extends StatelessWidget {
  final BluetoothEquipmentModel bluetoothEquipment;
  const _BikeItem({
    super.key,
    required this.bluetoothEquipment,
  });

  @override
  Widget build(BuildContext context) {
    final BluetoothBikeCubit bluetoothBikeCubit =
        context.read<BluetoothBikeCubit>();

    return BlocConsumer<BluetoothBikeCubit, BluetoothBikeState>(
      bloc: bluetoothBikeCubit,
      listener: (context, state) {},
      builder: (context, state) {
        final bool connected = state is BluetoothBikeConnected &&
            state.equipment == bluetoothEquipment;

        return GestureDetector(
          onTap: () => connected
              ? bluetoothBikeCubit.disconnect()
              : bluetoothBikeCubit.connect(bluetoothEquipment),
          child: BluetoothItemWidget(
            bluetoothEquipment: bluetoothEquipment,
            isConnecting: state is BluetoothBikeConnecting &&
                state.equipment == bluetoothEquipment,
            connected: connected,
          ),
        );
      },
    );
  }
}

class _TreadmillItem extends StatelessWidget {
  final BluetoothEquipmentModel bluetoothEquipment;
  const _TreadmillItem({
    super.key,
    required this.bluetoothEquipment,
  });

  @override
  Widget build(BuildContext context) {
    final BluetoothTreadmillCubit bluetoothTreadmillCubit =
        context.read<BluetoothTreadmillCubit>();

    return BlocConsumer<BluetoothTreadmillCubit, BluetoothTreadmillState>(
      bloc: bluetoothTreadmillCubit,
      listener: (context, state) {},
      builder: (context, state) {
        final bool connected = state is BluetoothTreadmillConnected &&
            state.equipment == bluetoothEquipment;

        return GestureDetector(
          onTap: () => connected
              ? bluetoothTreadmillCubit.disconnect()
              : bluetoothTreadmillCubit.connect(bluetoothEquipment),
          child: BluetoothItemWidget(
            bluetoothEquipment: bluetoothEquipment,
            isConnecting: state is BluetoothTreadmillConnecting &&
                state.equipment == bluetoothEquipment,
            connected: connected,
          ),
        );
      },
    );
  }
}

class BluetoothItemWidget extends StatelessWidget {
  final BluetoothEquipmentModel bluetoothEquipment;
  final bool isConnecting;
  final bool connected;
  const BluetoothItemWidget({
    required this.bluetoothEquipment,
    this.connected = false,
    this.isConnecting = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothEquipmentsCubit, BluetoothEquipmentsState>(
        builder: (context, state) {
      return Card(
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
              '${bluetoothEquipment.id} - ${bluetoothEquipment.equipment.name}'),
          subtitle: Text(bluetoothEquipment.equipmentType.name),
          trailing: isConnecting
              ? const CircularProgressIndicator()
              : connected
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
      );
    });
  }
}
