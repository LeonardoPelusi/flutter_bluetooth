part of 'metrics_notifiers.dart';

class BleBikeMetricsNotifier extends ChangeNotifier {
  static BleBikeMetricsNotifier instance = BleBikeMetricsNotifier();

  // Verificar se há bike conectada atualmente
  static ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  //Métricas que serão exibidas
  static ValueNotifier<int> instaCadence = ValueNotifier<int>(0);
  static ValueNotifier<int> instaPower = ValueNotifier<int>(-1);
  static ValueNotifier<int> resistanceLevel = ValueNotifier<int>(0);
  static ValueNotifier<double> speed = ValueNotifier<double>(0);

  void updateIsConnectedValue(bool newValue) {
    isConnected.value = newValue;
    notifyListeners();
  }

  void updateMetrics({
    required int newInstaCadence,
    required int newInstaPower,
    required int newResistanceLevel,
    required double newSpeed,
  }) {
    instaCadence.value = newInstaCadence;
    instaPower.value = newInstaPower;
    resistanceLevel.value = newResistanceLevel;
    speed.value = newSpeed;
    notifyListeners();
  }

  void clearMetrics() {
    instaCadence.value = 0;
    instaPower.value = -1;
    resistanceLevel.value = 0;
    speed.value = 0;
    notifyListeners();
  }
}
