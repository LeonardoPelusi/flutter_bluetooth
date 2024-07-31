import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'src/features/goper_aluno_core.dart';

class Bluetooth {
  String? deviceIdBLEConnection;

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

  late int lastCrankRev;
  late int lastTimeMeasured;
  int currentCrankRev = 0;
  int currentTimeMeasured = 0;
  late int diffCrankRev;
  late int diffTimeMeasured;

  static int securityZoneForCadence = 140;

  //valores características dos serviços bluetooth
  static ValueNotifier<int> instaCadence = ValueNotifier<int>(0);
  static ValueNotifier<int> instaPower = ValueNotifier<int>(-1);
  static ValueNotifier<int> resistanceLevel = ValueNotifier<int>(0);

  //valores treino com bike e treadmill
  static ValueNotifier<int> powerMedia = ValueNotifier<int>(0);
  static ValueNotifier<double> speed = ValueNotifier<double>(0);
  static ValueNotifier<double> inclination = ValueNotifier<double>(0);

  static ValueNotifier<int> cumulativePower = ValueNotifier<int>(0);
  static ValueNotifier<int> powerLength = ValueNotifier<int>(0);

  static ValueNotifier<bool> broadcastKeiser = ValueNotifier<bool>(false);

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

  // resetData() {
  //   powerBest = 0;
  //   powerMedia.value = 0;
  //   cumulativePower.value = 0;
  //   cadenceBest = 0;
  //   cadenceMedia = 0;
  //   speedMedia = 0;
  //   speedBest = 0;
  //   speedLength = 0;
  //   cumulativeSpeed = 0;

  //   cleanBikeData();
  //   cleanHeartRateData();
  //   cleanTreadmillData();
  //   clearUserData();
  // }

  // disconnectBluetoothDevices() {
  //   heartRateDevice?.device.disconnect();
  //   bikeDevice?.device.disconnect();
  //   treadmillDevice?.device.disconnect();
  //   bikeCharacteristicStream?.cancel();
  //   ziyouCharacteristicStream?.cancel();
  // }
}

// class DeviceWithId extends Equatable {
//   final BluetoothDevice device;
//   final String id;
//   final BluetothEquipmentType equipmentType;

//   DeviceWithId({
//     required this.device,
//     required this.id,
//     this.equipmentType = BluetothEquipmentType.undefined,
//   });

//   @override
//   List<Object?> get props {
//     return [
//       device,
//       id,
//       equipmentType,
//     ];
//   }
// }

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
