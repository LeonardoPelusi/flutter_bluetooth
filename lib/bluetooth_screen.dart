import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth/grid_view_widget.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/enums/bluetooth_connect_ftms_enum.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/domain/models/bluetooth_equipment_model.dart';
import 'package:flutter_bluetooth/src/features/bluetooth/ui/blocs/bluetooth_equipments_list_bloc/bluetooth_equipments_list_bloc.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothEquipmentsListBloc>(
          create: (context) => BluetoothEquipmentsListBloc(
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
        title: const Text('Bluetooth'),
      ),
      body: BlocBuilder<BluetoothEquipmentsListBloc,
              BluetoothEquipmentsListState>(
          bloc: _bluetoothEquipmentsListBloc,
          builder: (context, state) {
            if (state is BluetoothEquipmentsListInitialState) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    _bluetoothEquipmentsListBloc.add(
                      BluetoothEquipmentsListStartScanEvent(),
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No Bluetooth Devices Found'),
                    ElevatedButton(
                      onPressed: () {
                        _bluetoothEquipmentsListBloc.add(
                          BluetoothEquipmentsListStartScanEvent(),
                        );
                      },
                      child: const Text('Restart Scan'),
                    ),
                  ],
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

                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.005,
                            ),
                            child: BluetoothItemWidget(
                              bluetoothEquipment: bluetoothEquipment,
                            ),
                          ),
                          if (index ==
                                  state.bluetoothEquipments.indexOf(
                                      state.bluetoothEquipments.last) &&
                              state is BluetoothEquipmentsListAddEquipmentState)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: const CircularProgressIndicator(),
                            ),
                        ],
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
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
          trailing: const Text(
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
  }
}
