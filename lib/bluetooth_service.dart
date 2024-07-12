import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'src/features/goper_aluno_core.dart';

class Bluetooth {
  String? deviceIdBLEConnection;

  static DeviceWithId? heartRateDevice;
  static DeviceWithId? bikeDevice;
  static DeviceWithId? treadmillDevice;

  //list of connected devides [0: hearRate, 1: bike, 2: treadmill]
  static ValueNotifier<List<bool>> connectedDevices =
      ValueNotifier<List<bool>>([false, false, false]);

  static ValueNotifier<HeartRateBleController> heartRateConnected =
      ValueNotifier<HeartRateBleController>(
          HeartRateBleController(deviceConnected: false, open: true));

  static ValueNotifier<BikeBleController> bikeConnected =
      ValueNotifier<BikeBleController>(BikeBleController(
          deviceConnected: false, openBox: true, openFooter: true));

  static ValueNotifier<TreadmillBleController> treadmillConnected =
      ValueNotifier<TreadmillBleController>(TreadmillBleController(
          deviceConnected: false, openBox: true, openFooter: true));

  static ValueNotifier<bool> ftpConnected = ValueNotifier<bool>(false);

  late BluetoothService _heartRateService;
  late BluetoothService _userDataService;
  late BluetoothService _fitnessMachineService;
  late BluetoothService _CSCService;

  late BluetoothCharacteristic _heartRateMeasurement;
  BluetoothCharacteristic? _userAge;
  BluetoothCharacteristic? _userWeight;
  late BluetoothCharacteristic _bikeIndoorData;
  late BluetoothCharacteristic _treadmillFitnessData;
  late BluetoothCharacteristic _bikeZiyouData;

  StreamSubscription? heartCharacteristicStream;
  StreamSubscription? bikeCharacteristicStream;
  StreamSubscription? treadmillCharacteristicStream;
  StreamSubscription? ziyouCharacteristicStream;

  late List<int> bpm;
  late List<int> bikeData;
  late List<int> treadmillData;

  double cadenceResolution = 0.5;

  late int lastCrankRev;
  late int lastTimeMeasured;
  int currentCrankRev = 0;
  int currentTimeMeasured = 0;
  late int diffCrankRev;
  late int diffTimeMeasured;

  static int securityZoneForCadence = 140;

  //valores características dos serviços bluetooth
  static ValueNotifier<int> bpmValue = ValueNotifier<int>(-1);
  static ValueNotifier<int> instaCadence = ValueNotifier<int>(0);
  static ValueNotifier<int> instaPower = ValueNotifier<int>(-1);
  static ValueNotifier<int> resistanceLevel = ValueNotifier<int>(0);

  //valores treino com bike e treadmill
  static ValueNotifier<int> powerMedia = ValueNotifier<int>(0);
  static ValueNotifier<double> speed = ValueNotifier<double>(0);
  static ValueNotifier<double> inclination = ValueNotifier<double>(0);

  static ValueNotifier<int> cumulativePower = ValueNotifier<int>(0);
  static ValueNotifier<int> powerLength = ValueNotifier<int>(0);
  static ValueNotifier<bool?> bleOn = ValueNotifier<bool?>(null);

  static ValueNotifier<bool> broadcastKeiser = ValueNotifier<bool>(false);

  static int bpmMedia = 0;
  static int bpmBest = 0;
  static int cumulativeBpm = 0;

  static int powerBest = 0;

  static int cadenceMedia = 0;
  static int cadenceBest = 0;
  static int cumulativeCadence = 0;
  static int cadenceLength = 0;

  static double speedMedia = 0;
  static double speedBest = 0;
  static double cumulativeSpeed = 0;
  static int speedLength = 0;

  static int get equipmentType {
    if (Bluetooth.treadmillConnected.value.deviceConnected) {
      return 2;
    } else if (Bluetooth.bikeConnected.value.deviceConnected) {
      return 1;
    } else if (Bluetooth.heartRateConnected.value.deviceConnected) {
      return 3;
    } else {
      return 0;
    }
  }

  //seleciona o servico de user data para escrever os campos idade e peso
  getUserData(List<BluetoothService> _services, int idade, double peso) async {
    clearUserData();

    _userDataService = _services.firstWhere((service) =>
        service.uuid == Guid('0000181c-0000-1000-8000-00805f9b34fb'));

    _userAge = _userDataService.characteristics.firstWhere((characteristic) =>
        characteristic.uuid == Guid('00002a80-0000-1000-8000-00805f9b34fb'));

    _userWeight = _userDataService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid ==
            Guid('00002a98-0000-1000-8000-00805f9b34fb'));

    int pesoDecimal = int.tryParse(peso.toString().split('.')[1])!;

    await _userAge!.write([idade]);
    await _userWeight!.write([peso.truncate(), pesoDecimal]);

    List<int> age = await _userAge!.read();
    List<int> weight = await _userWeight!.read();
  }

  //seleciona servico do heart rate para imprimir o heart rate measurement (BPM)
  getHeartRateMeasurement(List<BluetoothService> _services) async {
    _heartRateService = _services.firstWhere((service) =>
        service.uuid == Guid('0000180d-0000-1000-8000-00805f9b34fb'));

    _heartRateMeasurement = _heartRateService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid ==
            Guid('00002a37-0000-1000-8000-00805f9b34fb'));

    heartCharacteristicStream = _heartRateMeasurement.value.listen((value) {
      bpm = value;
      if (bpm.length > 1) bpmValue.value = bpm[1];
      if (bpmValue.value != 0) {
        if (bpmValue.value > bpmBest) bpmBest = bpmValue.value;
      }
    });
    Future.delayed(Duration(milliseconds: 1500));
    await _heartRateMeasurement.setNotifyValue(true);
  }

  //seleciona fitness service para capturar os valores de cadencia e potencia
  getIndoorBikeData(List<BluetoothService> _services) async {
    _fitnessMachineService = _services.firstWhere((service) =>
        service.uuid == Guid('00001826-0000-1000-8000-00805f9b34fb'));

    _bikeIndoorData = _fitnessMachineService.characteristics.firstWhere(
        (characteristic) =>
            characteristic.uuid ==
            Guid('00002ad2-0000-1000-8000-00805f9b34fb'));

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
        speed.value = calculateSpeed(instaPower.value);
      }
    });
    Future.delayed(Duration(milliseconds: 1500));
    await _bikeIndoorData.setNotifyValue(true);
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

  getZiyouBikeData(List<BluetoothService> _services) async {
    _CSCService = _services.firstWhere((service) =>
        service.uuid == Guid('00001816-0000-1000-8000-00805f9b34fb'));

    _bikeZiyouData = _CSCService.characteristics.firstWhere((characteristic) =>
        characteristic.uuid == Guid('00002a5b-0000-1000-8000-00805f9b34fb'));

    ziyouCharacteristicStream = _bikeZiyouData.value.listen((value) {
      lastCrankRev = currentCrankRev;
      lastTimeMeasured = currentTimeMeasured;
      currentCrankRev = (value[8] << 8 | (value[7]));
      currentTimeMeasured = (value[10] << 8 | (value[9]));

      if (lastTimeMeasured > currentTimeMeasured) {
        // de acordo com a documentação do serviço CSC, os valores do lastTimeMeasured
        // zeram a cada 64s, tendo valor máximo 65536ms. Dessa forma, caso o valor atual
        // seja menor do que o último valor medido, devemos tirar a diferença
        diffTimeMeasured = (currentTimeMeasured) - lastTimeMeasured + 65536;
      } else {
        diffTimeMeasured = currentTimeMeasured - lastTimeMeasured;
      }

      diffCrankRev = currentCrankRev - lastCrankRev;

      instaCadence.value = lastTimeMeasured == 0 ||
              lastTimeMeasured == currentTimeMeasured
          // caso seja a primeira medição, mostrar 0, pois são necessárias duas medições para o cálculo
          // caso o pedal esteja parado, também mostrar 0
          ? 0
          : ((diffCrankRev * 60000) / diffTimeMeasured).floor();
    });
    Future.delayed(Duration(milliseconds: 1500));
    await _bikeZiyouData.setNotifyValue(true);
  }

  resetData() {
    powerBest = 0;
    powerMedia.value = 0;
    cumulativePower.value = 0;
    cadenceBest = 0;
    cadenceMedia = 0;
    bpmBest = 0;
    bpmMedia = 0;
    speedMedia = 0;
    speedBest = 0;
    speedLength = 0;
    cumulativeSpeed = 0;

    cleanBikeData();
    cleanHeartRateData();
    cleanTreadmillData();
    clearUserData();
  }

  cleanBikeData() {
    instaPower.value = -1;
    instaCadence.value = 0;
    resistanceLevel.value = 0;
    speed.value = 0;
  }

  cleanHeartRateData() {
    bpmValue.value = -1;
  }

  clearUserData() {
    _userAge = null;
    _userWeight = null;
  }

  disconnectBluetoothDevices() {
    heartRateDevice?.device.disconnect();
    bikeDevice?.device.disconnect();
    treadmillDevice?.device.disconnect();
    bikeCharacteristicStream?.cancel();
    heartCharacteristicStream?.cancel();
    treadmillCharacteristicStream?.cancel();
    ziyouCharacteristicStream?.cancel();
  }

  double calculateSpeed(int power) {
    double num = (0.75 * power) / 0.19;
    return (pow(num, 1 / 3)) * 3.6;
  }
}

class DeviceWithId extends Equatable {
  final BluetoothDevice device;
  final String id;
  final BluetothEquipmentType equipmentType;

  DeviceWithId({
    required this.device,
    required this.id,
    this.equipmentType = BluetothEquipmentType.undefined,
  });

  @override
  List<Object?> get props {
    return [
      device,
      id,
      equipmentType,
    ];
  }
}

class HeartRateBleController {
  bool deviceConnected;
  bool open;

  HeartRateBleController({this.deviceConnected = false, this.open = false});
}

class BikeBleController {
  bool deviceConnected;
  bool openBox;
  bool openFooter;

  BikeBleController(
      {this.deviceConnected = false,
      this.openBox = false,
      this.openFooter = false});
}

class TreadmillBleController {
  bool deviceConnected;
  bool openBox;
  bool openFooter;

  TreadmillBleController(
      {this.deviceConnected = false,
      this.openBox = false,
      this.openFooter = false});
}
