import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/train_ride.dart' as model;
import '../../data/datasources/remote/baserow_api.dart';

part 'train_rides_provider.g.dart';

@riverpod
BaserowApi baserowApi(BaserowApiRef ref) {
  return BaserowApi();
}

@riverpod
class TrainRidesNotifier extends _$TrainRidesNotifier {
  @override
  Future<List<model.TrainRide>> build() async {
    final api = ref.read(baserowApiProvider);
    return await api.getTrainRides();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> addTrainRide(model.TrainRide ride) async {
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(baserowApiProvider);
      await api.createTrainRide(ride);
      
      // Refresh the list after adding
      final updatedRides = await api.getTrainRides();
      state = AsyncValue.data(updatedRides);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTrainRide(model.TrainRide ride) async {
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(baserowApiProvider);
      await api.updateTrainRide(ride);
      
      // Refresh the list after updating
      final updatedRides = await api.getTrainRides();
      state = AsyncValue.data(updatedRides);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTrainRide(int id) async {
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(baserowApiProvider);
      await api.deleteTrainRide(id);
      
      // Refresh the list after deleting
      final updatedRides = await api.getTrainRides();
      state = AsyncValue.data(updatedRides);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

@riverpod
class TrainRideSearchNotifier extends _$TrainRideSearchNotifier {
  @override
  Future<List<model.TrainRide>> build(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    final api = ref.read(baserowApiProvider);
    final allRides = await api.getTrainRides();
    
    // Simple search in from, to, and details fields
    return allRides.where((ride) {
      final searchText = query.toLowerCase();
      return ride.from.toLowerCase().contains(searchText) ||
             ride.to.toLowerCase().contains(searchText) ||
             (ride.details?.toLowerCase().contains(searchText) ?? false);
    }).toList();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    
    try {
      final api = ref.read(baserowApiProvider);
      final allRides = await api.getTrainRides();
      
      final results = allRides.where((ride) {
        final searchText = query.toLowerCase();
        return ride.from.toLowerCase().contains(searchText) ||
               ride.to.toLowerCase().contains(searchText) ||
               (ride.details?.toLowerCase().contains(searchText) ?? false);
      }).toList();
      
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

@riverpod
Future<List<model.TrainRide>> trainRidesByDateRange(
  TrainRidesByDateRangeRef ref,
  DateTime start,
  DateTime end,
) async {
  final api = ref.read(baserowApiProvider);
  final allRides = await api.getTrainRides();
  
  return allRides.where((ride) {
    return ride.date.isAfter(start.subtract(const Duration(days: 1))) &&
           ride.date.isBefore(end.add(const Duration(days: 1)));
  }).toList();
}

@riverpod
Future<model.TrainRide?> trainRideById(
  TrainRideByIdRef ref,
  int id,
) async {
  final api = ref.read(baserowApiProvider);
  final allRides = await api.getTrainRides();
  
  try {
    return allRides.firstWhere((ride) => ride.id == id);
  } catch (e) {
    return null;
  }
}

