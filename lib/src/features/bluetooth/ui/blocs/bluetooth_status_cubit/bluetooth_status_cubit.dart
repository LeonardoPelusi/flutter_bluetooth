import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'bluetooth_status_state.dart';

abstract class BluetoothStatusCubit extends Cubit<BluetoothStatusState> {
  BluetoothStatusCubit()
      : super(
          const BluetoothStatusState(status: BluetoothStatus.initial),
        ) {
    listenToBluetoothStatus();
  }

  Future<void> listenToBluetoothStatus();
}

class BluetoothStatusCubitImpl extends BluetoothStatusCubit {
  @override
  Future<void> listenToBluetoothStatus() async {
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      emit(const BluetoothStatusState(status: BluetoothStatus.unavailable));
      // handle bluetooth on & off
      // note: for iOS the initial state is typically BluetoothAdapterState.unknown
      // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    } else {
      FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        if (state == BluetoothAdapterState.on ||
            state == BluetoothAdapterState.turningOn) {
          emit(const BluetoothStatusState(status: BluetoothStatus.connected));
        } else if (state == BluetoothAdapterState.off ||
            state == BluetoothAdapterState.turningOff) {
          emit(
              const BluetoothStatusState(status: BluetoothStatus.disconnected));
        } else {
          emit(const BluetoothStatusState(status: BluetoothStatus.error));
        }
      });
    }
  }
}
