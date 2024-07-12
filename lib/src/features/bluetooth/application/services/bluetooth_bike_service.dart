part of 'bluetooth_equipment_service.dart';

class BluetoothBikeService {
  static BluetoothBikeService get instance => BluetoothBikeService();

  // Equipamento Conectado Atualmente
  BluetoothEquipmentModel? connectedBike;

  //Métricas que serão exibidas
  static ValueNotifier<int> instaCadence = ValueNotifier<int>(0);
  static ValueNotifier<int> instaPower = ValueNotifier<int>(-1);
  static ValueNotifier<int> resistanceLevel = ValueNotifier<int>(0);
  static ValueNotifier<double> speed = ValueNotifier<double>(0);

  _cleanBikeData() {
    instaPower.value = -1;
    instaCadence.value = 0;
    resistanceLevel.value = 0;
    speed.value = 0;
  }
}
