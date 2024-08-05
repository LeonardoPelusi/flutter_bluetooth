part of 'metrics_notifiers.dart';

class BleFrequencyMeterMetricsNotifier extends ChangeNotifier {
  static BleFrequencyMeterMetricsNotifier instance =
      BleFrequencyMeterMetricsNotifier();

  // Verificar se há frequencímetro conectada atualmente
  static ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  //Métricas que serão exibidas
  static ValueNotifier<int> bpmValue = ValueNotifier<int>(-1);

  void updateIsConnectedValue(bool newValue) {
    isConnected.value = newValue;
    notifyListeners();
  }

  void updateMetrics({required int newBpm}) {
    bpmValue.value = newBpm;
    notifyListeners();
  }

  void clearData() {
    isConnected.value = false;
    bpmValue.value = -1;
    notifyListeners();
  }
}
