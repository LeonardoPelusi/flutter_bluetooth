part of 'metrics_notifiers.dart';

class BleBikeMetricsNotifier extends ChangeNotifier {
  static BleBikeMetricsNotifier instance = BleBikeMetricsNotifier();

  // Verificar se há bike conectada atualmente
  static ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  //Métricas que serão exibidas
  static ValueNotifier<int> cadence = ValueNotifier<int>(0);
  static ValueNotifier<int> power = ValueNotifier<int>(-1);
  static ValueNotifier<int> resistance = ValueNotifier<int>(0);
  static ValueNotifier<double> speed = ValueNotifier<double>(0);

  void updateIsConnectedValue(bool newValue) {
    isConnected.value = newValue;
    notifyListeners();
  }

  void updateMetrics({
    required int newCadence,
    required int newPower,
    required int newResistance,
    required double newSpeed,
  }) {
    cadence.value = newCadence;
    power.value = newPower;
    resistance.value = newResistance;
    speed.value = newSpeed;
    notifyListeners();
  }

  void clearMetrics() {
    cadence.value = 0;
    power.value = -1;
    resistance.value = 0;
    speed.value = 0;
    notifyListeners();
  }
}
