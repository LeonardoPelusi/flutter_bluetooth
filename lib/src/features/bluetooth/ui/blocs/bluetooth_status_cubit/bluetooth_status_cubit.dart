import 'package:bloc/bloc.dart';
  import 'package:flutter_blue_plus/flutter_blue_plus.dart';

part 'bluetooth_status_state.dart';

abstract class BluetoothStatusCubit extends Cubit<BluetoothStatusState> {
  BluetoothStatusCubit() : super(BluetoothStatusState.initial) {
    listenToBluetoothStatus();
  }

  void listenToBluetoothStatus();
}

class BluetoothStatusCubitImpl extends BluetoothStatusCubit {
  // Packages
  final FlutterBluePlus _flutterBluePlus = FlutterBluePlus.instance;

  @override
  void listenToBluetoothStatus() {
    _flutterBluePlus.state.listen((event) {
      if (event == BluetoothState.on || event == BluetoothState.turningOn) {
        emit(BluetoothStatusState.connected);
      } else if (event == BluetoothState.turningOff ||
          event == BluetoothState.off) {
        emit(BluetoothStatusState.disconnected);
      } else {
        emit(BluetoothStatusState.error);
      }
    });
  }
}
