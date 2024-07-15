// import 'package:flutter_bluetooth/src/features/bluetooth/application/bluetooth_helper.dart';
// import 'package:flutter_bluetooth/src/features/bluetooth/domain/bluetooth_equipment_enum.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// class BluetoothSharedPreferencesService {
//   BluetoothSharedPreferencesService(
//     this._sharedPreferences,
//     this._bluetoothSharedPreferences,
//   );

//   final SharedPreferences _sharedPreferences;
//   final BluetoothSharedPreferences _bluetoothSharedPreferences;

//   String get equipmentId => _bluetoothSharedPreferences.equipmentId;

//   bool get _haveValueInSharedPreferences =>
//       _bluetoothSharedPreferences.equipmentId.isNotEmpty;

//   bool get bikeOnSharedPreferences =>
//       _haveValueInSharedPreferences &&
//       (_bluetoothSharedPreferences.bluetoothEquipmentType ==
//               BluetoothEquipmentType.bikeGoper ||
//           _bluetoothSharedPreferences.bluetoothEquipmentType ==
//               BluetoothEquipmentType.bikeKeiser);

//   bool get haveTreadmillOnSharedPreferences =>
//       _haveValueInSharedPreferences &&
//       _bluetoothSharedPreferences.bluetoothEquipmentType ==
//           BluetoothEquipmentType.treadmill;

//   List<Guid> getServicesValidation() {
//     if (_haveValueInSharedPreferences) {
//       if (_bluetoothSharedPreferences.bluetoothEquipmentType ==
//           BluetoothEquipmentType.bikeGoper) {
//         return BluetoothHelper.servicesFilterList();
//       } else if (_bluetoothSharedPreferences.bluetoothEquipmentType ==
//           BluetoothEquipmentType.bikeKeiser) {
//         return [];
//       } else if (_bluetoothSharedPreferences.bluetoothEquipmentType ==
//           BluetoothEquipmentType.treadmill) {
//         return BluetoothHelper.servicesFilterList();
//       }
//     }
//     return [];
//   }

//   Future<void> bluetoothCryptoBikeGoper({
//     required String bikeId,
//   }) async {
//     await _sharedPreferences.bluetoothCrypto(
//       equipmentId: bikeId,
//       bluetoothEquipmentType: BluetoothEquipmentType.bikeGoper,
//     );
//   }

//   Future<void> bluetoothCryptoBikeKeiser({
//     required String bikeKeiserId,
//   }) async {
//     await _sharedPreferences.bluetoothCrypto(
//       equipmentId: bikeKeiserId,
//       bluetoothEquipmentType: BluetoothEquipmentType.bikeKeiser,
//     );
//   }

//   Future<void> bluetoothCryptoTreadmillBLE({
//     required String treadmillId,
//   }) async {
//     await _sharedPreferences.bluetoothCrypto(
//       equipmentId: treadmillId,
//       bluetoothEquipmentType: BluetoothEquipmentType.treadmill,
//     );
//   }
// }
