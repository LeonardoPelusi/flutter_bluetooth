import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'bluetooth_status_state.dart';

abstract class BluetoothStatusCubit extends Cubit<BluetoothStatusState> {
  BluetoothStatusCubit() : super(BluetoothStatusState.initial) {
    listenToBluetoothStatus();
  }

  Future<void> listenToBluetoothStatus();
}

class BluetoothStatusCubitImpl extends BluetoothStatusCubit {
  @override
  Future<void> listenToBluetoothStatus() async {
    if (await FlutterBluePlus.isAvailable == false) {
      emit(BluetoothStatusState.unavailable);
      return;
    } else {
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        if (state == BluetoothAdapterState.on ||
            state == BluetoothAdapterState.turningOn) {
          emit(BluetoothStatusState.connected);
        } else if (state == BluetoothAdapterState.off ||
            state == BluetoothAdapterState.turningOff) {
          emit(BluetoothStatusState.disconnected);
        } else {
          emit(BluetoothStatusState.error);
        }
      });
    }
  }
}
