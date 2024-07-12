part of 'bluetooth_equipment_service.dart';

class BluetoothFrequencyMeterService {
  static BluetoothFrequencyMeterService get instance =>
      BluetoothFrequencyMeterService();

  // Equipamento Conectado Atualmente
  BluetoothEquipmentModel? connectedFrequencyMeter;

  //Métricas que serão exibidas
  static ValueNotifier<int> bpmValue = ValueNotifier<int>(-1);

  int bpmMedia = 0;
  int bpmBest = 0;
  int cumulativeBpm = 0;

  // Serviços - Usuário
  late BluetoothService _userDataService;
  BluetoothCharacteristic? _userAge;
  BluetoothCharacteristic? _userWeight;

  // Serviços - Usuário
  late BluetoothService _frequencyMeterService;
  BluetoothCharacteristic? _frequencyMeterMeasurement;

  // Stream
  StreamSubscription? _frequencyMeterCharacteristicStream;

  // Dados
  late List<int> bpmData;

  //seleciona o servico de user data para escrever os campos idade e peso
  Future<void> getUserData(
      List<BluetoothService> _services, int idade, double peso) async {
    _clearUserData();

    _userDataService = _services.firstWhere(
      (service) =>
          service.uuid == BluetoothEquipmentService.guids.userDataService,
    );

    _userAge = _userDataService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.uuid == BluetoothEquipmentService.guids.userAge,
    );

    _userWeight = _userDataService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.uuid == BluetoothEquipmentService.guids.userWeight,
    );

    int pesoDecimal = int.tryParse(peso.toString().split('.')[1])!;

    await _userAge!.write([idade]);
    await _userWeight!.write([peso.truncate(), pesoDecimal]);

    List<int> age = await _userAge!.read();
    List<int> weight = await _userWeight!.read();
  }

  //seleciona servico do frequency meter para imprimir o frequency meter measurement (BPM)
  Future<void> getFrequencyMeterMeasurement(
      List<BluetoothService> _services) async {
    _cleanFequencyMeterData();

    _frequencyMeterService = _services.firstWhere(
      (service) =>
          service.uuid == BluetoothEquipmentService.guids.frequencyMeterService,
    );

    _frequencyMeterMeasurement =
        _frequencyMeterService.characteristics.firstWhere(
      (characteristic) =>
          characteristic.uuid ==
          BluetoothEquipmentService.guids.frequencyMeterMeasurement,
    );

    _frequencyMeterCharacteristicStream =
        _frequencyMeterMeasurement!.value.listen((value) {
      bpmData = value;
      if (bpmData.length > 1) bpmValue.value = bpmData[1];
      if (bpmValue.value != 0) {
        if (bpmValue.value > bpmBest) bpmBest = bpmValue.value;
      }
    });
    Future.delayed(const Duration(milliseconds: 1500));
    await _frequencyMeterMeasurement!.setNotifyValue(true);
  }

  void _clearUserData() {
    _userAge = null;
    _userWeight = null;
  }

  void _cleanFequencyMeterData() {
    connectedFrequencyMeter = null;
    bpmValue.value = -1;
    bpmBest = 0;
    bpmMedia = 0;
    _frequencyMeterCharacteristicStream?.cancel();
    _frequencyMeterCharacteristicStream = null;
  }

  void disconnectFrequencyMeter() {
    _clearUserData();
    _cleanFequencyMeterData();
  }
}
