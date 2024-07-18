import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth/bluetooth_metrics_screen.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_connect_ftms_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipment_bloc/bluetooth_equipment_bloc.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipments_bloc/bluetooth_equipments_list_bloc.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_status_cubit/bluetooth_status_cubit.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothStatusCubit>(
          create: (_) => BluetoothStatusCubitImpl(),
        ),
        BlocProvider<BluetoothEquipmentsListBloc>(
          create: (context) => BluetoothEquipmentsListBloc(
            context.read<BluetoothStatusCubit>(),
            bluetoothConnectFTMS: BluetoothConnectFTMS.all,
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
  late final BluetoothEquipmentsListBloc _bluetoothEquipmentsListBloc;

  @override
  void initState() {
    super.initState();
    _bluetoothEquipmentsListBloc = context.read<BluetoothEquipmentsListBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth'),
        actions: [
          IconButton(
            onPressed: () => _bluetoothEquipmentsListBloc
                .add(BluetoothEquipmentsListNewScanEvent()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<BluetoothEquipmentsListBloc,
              BluetoothEquipmentsListState>(
          bloc: _bluetoothEquipmentsListBloc,
          builder: (context, state) {
            print(state);
            if (state is BluetoothEquipmentsListInitialState) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    _bluetoothEquipmentsListBloc.add(
                      BluetoothEquipmentsListNewScanEvent(),
                    );
                  },
                  child: const Text('Start Scan'),
                ),
              );
            }
            if (state is BluetoothEquipmentsListLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.bluetoothEquipments.isEmpty) {
              return Container();
            }

            return ListView.builder(
              // itemCount: state.bluetoothEquipments.length,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.025,
              ),
              itemCount: state.bluetoothEquipments.length,
              itemBuilder: (ctx, index) {
                final bluetoothEquipment = state.bluetoothEquipments[index];

                return Column(
                  children: [
                    BlocProvider<BluetoothEquipmentBloc>(
                      create: (_) => BluetoothEquipmentBloc(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.005,
                        ),
                        child: BluetoothItemWidget(
                          bluetoothEquipment: bluetoothEquipment,
                        ),
                      ),
                    ),
                    if (index ==
                            state.bluetoothEquipments
                                .indexOf(state.bluetoothEquipments.last) &&
                        state is BluetoothEquipmentsListAddEquipmentState)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: const CircularProgressIndicator(),
                      ),
                  ],
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
        bloc: _bluetoothEquipmentBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BluetoothMetricsScreen(
                    bluetoothEquipment: widget.bluetoothEquipment,
                  ),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Colors.black,
                ),
              ),
              elevation: 16,
              shadowColor: Colors.black,
              child: ListTile(
                title: Text(
                    '${widget.bluetoothEquipment.id} - ${widget.bluetoothEquipment.equipment.name}'),
                subtitle: Text(widget.bluetoothEquipment.equipmentType.name),
                trailing: state is BluetoothEquipmentConnectingState
                    ? const CircularProgressIndicator()
                    : state is BluetoothEquipmentConnectedState
                        ? const Icon(Icons.arrow_forward_ios)
                        : TextButton(
                            onPressed: () {
                              _bluetoothEquipmentBloc
                                  .add(BluetoothEquipmentConnectEvent(
                                bluetoothEquipment: widget.bluetoothEquipment,
                              ));
                            },
                            child: Text('Conectar'),
                          ),
              ),
            ),
          );
        });
  }
}
