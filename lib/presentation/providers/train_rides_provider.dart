import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/train_ride.dart' as model;
import '../../data/datasources/remote/supabase_api.dart';

part 'train_rides_provider.g.dart';

@riverpod
SupabaseApi supabaseApi(SupabaseApiRef ref) {
  return SupabaseApi(Supabase.instance.client);
}

@riverpod
class TrainRidesNotifier extends _$TrainRidesNotifier {
  @override
  Future<List<model.TrainRide>> build() async {
    final api = ref.read(supabaseApiProvider);
    return await api.fetchRides();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> addTrainRide(model.TrainRide ride) async {
    try {
      final api = ref.read(supabaseApiProvider);
      await api.addRide(ride.toJson());
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTrainRide(model.TrainRide ride) async {
    try {
      final api = ref.read(supabaseApiProvider);
      await api.updateRide(ride.id!, ride.toJson());
      ref.invalidateSelf();

      // Invalidate the individual ride cache
      if (ride.id != null) {
        ref.invalidate(trainRideByIdProvider(ride.id!));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTrainRide(int id) async {
    try {
      final api = ref.read(supabaseApiProvider);
      await api.deleteRide(id);
      ref.invalidateSelf();

      // Invalidate the individual ride cache
      ref.invalidate(trainRideByIdProvider(id));
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

    // Use shared cache from main provider
    final allRidesAsync = ref.watch(trainRidesNotifierProvider);
    final allRides = allRidesAsync.when(
      data: (rides) => rides,
      loading: () => <model.TrainRide>[],
      error: (error, stack) => throw error,
    );

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
      // Use shared cache from main provider
      final allRidesAsync = ref.read(trainRidesNotifierProvider);
      final allRides = allRidesAsync.when(
        data: (rides) => rides,
        loading: () => <model.TrainRide>[],
        error: (error, stack) => throw error,
      );

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
  // Use shared cache from main provider
  final allRidesAsync = ref.watch(trainRidesNotifierProvider);
  final allRides = allRidesAsync.when(
    data: (rides) => rides,
    loading: () => <model.TrainRide>[],
    error: (error, stack) => throw error,
  );

  return allRides.where((ride) {
    return ride.date.isAfter(start.subtract(const Duration(days: 1))) &&
        ride.date.isBefore(end.add(const Duration(days: 1)));
  }).toList();
}

@riverpod
Future<model.TrainRide?> trainRideById(TrainRideByIdRef ref, int id) async {
  final api = ref.read(supabaseApiProvider);

  try {
    final list = await api.fetchRides();
    try {
      return list.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  } catch (e) {
    return null;
  }
}
