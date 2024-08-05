part of 'metrics_notifiers.dart';

class BleTreadmillMetricsNotifier extends ChangeNotifier {
  static BleTreadmillMetricsNotifier instance = BleTreadmillMetricsNotifier();

  // Verificar se há esteira conectada atualmente
  static ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  //Métricas que serão exibidas
  static ValueNotifier<double> speed = ValueNotifier<double>(0);
  static ValueNotifier<double> inclination = ValueNotifier<double>(0);
  static ValueNotifier<int> power = ValueNotifier<int>(-1);

  void updateIsConnectedValue(bool newValue) {
    isConnected.value = newValue;
    notifyListeners();
  }

  void updateMetrics({
    required double newSpeed,
    required double newInclination,
    required int newPower,
  }) {
    speed.value = newSpeed;
    inclination.value = newInclination;
    power.value = newPower;
    notifyListeners();
  }

  void clearData() {
    isConnected.value = false;
    speed.value = 0;
    inclination.value = 0;
    power.value = -1;
    notifyListeners();
  }
}
