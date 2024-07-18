part of 'metrics_notifiers.dart';

class BleTreadmillMetricsNotifier extends ChangeNotifier {
  static BleTreadmillMetricsNotifier instance = BleTreadmillMetricsNotifier();

  // Equipamento Conectado Atualmente
  static ValueNotifier<BluetoothEquipmentModel?> connectedTreadmill =
      ValueNotifier<BluetoothEquipmentModel?>(null);

  //Métricas que serão exibidas
  static ValueNotifier<int> instaPower = ValueNotifier<int>(-1);
  static ValueNotifier<double> speed = ValueNotifier<double>(0);
  static ValueNotifier<double> inclination = ValueNotifier<double>(0);

  void updateMetrics({
    required int newInstaPower,
    required double newSpeed,
    required double newInclination,
  }) {
    instaPower.value = newInstaPower;
    speed.value = newSpeed;
    inclination.value = newInclination;
    notifyListeners();
  }

  void clearMetrics() {
    instaPower.value = -1;
    speed.value = 0;
    inclination.value = 0;
    notifyListeners();
  }
}
