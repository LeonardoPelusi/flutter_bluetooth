part of 'metrics_notifiers.dart';

class BleFrequencyMeterMetricsNotifier extends ChangeNotifier {
  static BleFrequencyMeterMetricsNotifier instance =
      BleFrequencyMeterMetricsNotifier();

  //Métricas que serão exibidas
  static ValueNotifier<int> bpmValue = ValueNotifier<int>(-1);

  void updateMetrics({required int newBpm}) {
    bpmValue.value = newBpm;
    notifyListeners();
  }

  void clearMetrics() {
    bpmValue.value = -1;
    notifyListeners();
  }
}
