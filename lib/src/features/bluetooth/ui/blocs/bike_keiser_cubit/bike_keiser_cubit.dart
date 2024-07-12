import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goper_aluno_core/goper_aluno_core.dart';

part 'bike_keiser_state.dart';

abstract class BikeKeiserCubit extends Cubit<BikeKeiserState> {
  BikeKeiserCubit() : super(LoadingBikeKeiserData());

  Future<void> listenToBikeKeiserBroadcast({required String bikeId});
  Future<void> cancelBikeKeiserBroadcastDetection();
  void deinitialize();
  void newBroadcastRequested();
}

class BikeKeiserCubitImpl extends BikeKeiserCubit {
  BikeKeiserCubitImpl([BikeKeiserBroadcastsRepository? bikeKeiserBroadcastsRepository]) {
    _bikeKeiserBroadcastsRepository = bikeKeiserBroadcastsRepository ?? BikeKeiserBroadcastsRepositoryImpl();
  }

  late final BikeKeiserBroadcastsRepository _bikeKeiserBroadcastsRepository;
  StreamSubscription<BikeKeiserDeviceBroadcast>? _keiserBroadcastSubscription;

  @override
  Future<void> listenToBikeKeiserBroadcast({required String bikeId}) async {
    if (state is ListeningToBikeKeiserBroadcast) {
      return;
    }
    if(_keiserBroadcastSubscription == null) {
      _keiserBroadcastSubscription =
          _bikeKeiserBroadcastsRepository.bikeKeiserBroadcastFrom(
              bikeId).listen(_bikeKeiserBroadcastDetectionListener);
    } else {
      _keiserBroadcastSubscription!.resume();
      _keiserBroadcastSubscription!.onData((data) {
        _bikeKeiserBroadcastDetectionListener(data);
      });
    }
  }

  @override
  Future<void> cancelBikeKeiserBroadcastDetection() async {
    if (state is ListeningToBikeKeiserBroadcast) {
      final stateCast = state as ListeningToBikeKeiserBroadcast;
      _keiserBroadcastSubscription?.cancel();
      _keiserBroadcastSubscription = null;
      emit(BikeKeiserBroadcastDetectionCanceled(stateCast.bikeKeiserDeviceBroadcast));
    }
  }

  @override
  void newBroadcastRequested() {
    if (state is BikeKeiserBroadcastDetectionCanceled) {
      emit(LoadingBikeKeiserData());
      return;
    }
  }

  @override
  void deinitialize() {
    _bikeKeiserBroadcastsRepository.stopListening();
  }

  void _bikeKeiserBroadcastDetectionListener(BikeKeiserDeviceBroadcast bikeData) {
    if (state is LoadingBikeKeiserData) {
      emit(ListeningToBikeKeiserBroadcast(bikeKeiserDeviceBroadcast: bikeData));
      return;
    }
    if (state is ListeningToBikeKeiserBroadcast) {
      final stateCast = state as ListeningToBikeKeiserBroadcast;
      final newBroadcastFromSameBike = stateCast.bikeKeiserDeviceBroadcast.id == bikeData.id;
      if (!newBroadcastFromSameBike) {
        return;
      }
      emit(ListeningToBikeKeiserBroadcast(bikeKeiserDeviceBroadcast: bikeData));
    }
  }
}
