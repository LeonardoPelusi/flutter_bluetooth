part of 'bluetooth_equipment_service.dart';

class BluetoothBikeService {
  static BluetoothBikeService get _instance => BluetoothBikeService();

  // Equipamento Conectado Atualmente
  BluetoothEquipmentModel? connectedBike;

  //Métricas que serão exibidas
  ValueNotifier<int> instaCadence = ValueNotifier<int>(0);
  ValueNotifier<int> instaPower = ValueNotifier<int>(-1);
  ValueNotifier<int> resistanceLevel = ValueNotifier<int>(0);
  ValueNotifier<double> speed = ValueNotifier<double>(0);

  // Variáveis para a geração de graficos
  int powerBest = 0;
  int cadenceMedia = 0;
  int cadenceBest = 0;
  int cumulativeCadence = 0;
  int cadenceLength = 0;

  // Serviços
  late BluetoothService _fitnessMachineService;
  late BluetoothCharacteristic _bikeIndoorData;

  // Stream
  StreamSubscription? bikeCharacteristicStream;

  // Dados
  late List<int> bikeData;

  double cadenceResolution = 0.5;

  //seleciona fitness service para capturar os valores de cadencia e potencia
  void getIndoorBikeData(List<BluetoothService> _services) async {
    cleanBikeData();
    _fitnessMachineService = _services.firstWhere((service) =>
        service.uuid == BluetoothEquipmentService.guids.fitnessMachineService);

    _bikeIndoorData = _fitnessMachineService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid ==
            BluetoothEquipmentService.guids.bikeIndoorData);

    bikeCharacteristicStream = _bikeIndoorData.value.listen((value) {
      bikeData = value;
      int byte = 2;

      if (bikeData.isNotEmpty) {
        if (bikeData[0] & 0x01 == 0x00) byte += 2;

        if (bikeData[0] & 0x02 == 0x02) byte += 2;

        instaCadence.value =
            ((bikeData[byte + 1] << 8 | (bikeData[byte])) * cadenceResolution)
                .floor();

        byte += 2;

        if (bikeData[0] & 0x08 == 0x08) byte += 2;

        if (bikeData[0] & 0x10 == 0x10) byte += 2;

        if (bikeData[0] & 0x20 == 0x20) {
          resistanceLevel.value = _calculateResistance(bikeData[byte]);
          byte += 2;
        }

        // O código abaixo está fixando a potência máxima da bike como 999w
        // devido a um pedido da equipe que cuida da Bike Goper e
        // em 27/jun/2024
        int detectedPower = (bikeData[byte + 1] << 8 | (bikeData[byte]));
        instaPower.value = detectedPower <= 999 ? detectedPower : 999;

        if (instaCadence.value > cadenceBest) cadenceBest = instaCadence.value;

        // calcular média de cadência
        cadenceLength++;
        cadenceMedia =
            ((instaCadence.value + cumulativeCadence) / cadenceLength).round();
        cumulativeCadence += instaCadence.value;

        if (instaPower.value > powerBest) powerBest = instaPower.value;
        speed.value = _calculateSpeed(instaPower.value);
      }
    });
    Future.delayed(const Duration(milliseconds: 1500));
    await _bikeIndoorData.setNotifyValue(true);
  }

  void cleanBikeData() {
    connectedBike = null;
    instaPower.value = -1;
    instaCadence.value = 0;
    resistanceLevel.value = 0;
    speed.value = 0;
  }

  void disconnectBike() {
    cleanBikeData();
  }

  double _calculateSpeed(int power) {
    double num = (0.75 * power) / 0.19;
    return (pow(num, 1 / 3)) * 3.6;
  }

  int _calculateResistance(int resistanceValue) {
    if (resistanceValue < 5) {
      return 1;
    } else {
      if (resistanceValue < 10) {
        return 2;
      } else {
        if (resistanceValue < 15) {
          return 3;
        } else {
          if (resistanceValue < 19) {
            return 4;
          } else {
            if (resistanceValue < 23) {
              return 5;
            } else {
              if (resistanceValue < 27) {
                return 6;
              } else {
                if (resistanceValue < 31) {
                  return 7;
                } else {
                  if (resistanceValue < 35) {
                    return 8;
                  } else {
                    if (resistanceValue < 39) {
                      return 9;
                    } else {
                      if (resistanceValue < 43) {
                        return 10;
                      } else {
                        if (resistanceValue < 47) {
                          return 11;
                        } else {
                          if (resistanceValue < 51) {
                            return 12;
                          } else {
                            if (resistanceValue < 55) {
                              return 13;
                            } else {
                              if (resistanceValue < 59) {
                                return 14;
                              } else {
                                if (resistanceValue < 63) {
                                  return 15;
                                } else {
                                  if (resistanceValue < 67) {
                                    return 16;
                                  } else {
                                    if (resistanceValue < 71) {
                                      return 17;
                                    } else {
                                      if (resistanceValue < 75) {
                                        return 18;
                                      } else {
                                        if (resistanceValue < 79) {
                                          return 19;
                                        } else if (resistanceValue == 80) {
                                          return 20;
                                        } else if (resistanceValue == 81) {
                                          return 21;
                                        } else if (resistanceValue == 82) {
                                          return 22;
                                        } else if (resistanceValue == 83) {
                                          return 23;
                                        } else if (resistanceValue == 84) {
                                          return 24;
                                        } else if (resistanceValue == 85) {
                                          return 25;
                                        } else if (resistanceValue == 86) {
                                          return 26;
                                        } else if (resistanceValue == 87) {
                                          return 27;
                                        } else if (resistanceValue == 88) {
                                          return 28;
                                        } else if (resistanceValue == 89) {
                                          return 29;
                                        } else if (resistanceValue == 90) {
                                          return 30;
                                        } else if (resistanceValue == 91) {
                                          return 31;
                                        } else if (resistanceValue == 92) {
                                          return 32;
                                        } else if (resistanceValue == 93) {
                                          return 33;
                                        } else if (resistanceValue == 94) {
                                          return 34;
                                        } else if (resistanceValue == 95) {
                                          return 35;
                                        } else if (resistanceValue == 96) {
                                          return 36;
                                        } else if (resistanceValue == 97) {
                                          return 37;
                                        } else if (resistanceValue == 98) {
                                          return 38;
                                        } else if (resistanceValue == 99) {
                                          return 39;
                                        } else if (resistanceValue == 100) {
                                          return 40;
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
                return 0;
              }
            }
          }
        }
      }
    }
  }
}
