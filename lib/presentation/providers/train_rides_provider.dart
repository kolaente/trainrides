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
      final currentUser = api.client.auth.currentUser;

      if (currentUser == null) {
        throw Exception(
          'You must be signed in to add train rides. Please sign in and try again.',
        );
      }

      // Ensure the ride includes the current user's ID
      final rideWithUserId = ride.copyWith(userId: currentUser.id);
      await api.addRide(rideWithUserId.toJson());
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTrainRide(model.TrainRide ride) async {
    try {
      final api = ref.read(supabaseApiProvider);
      final currentUser = api.client.auth.currentUser;

      if (currentUser == null) {
        throw Exception(
          'You must be signed in to update train rides. Please sign in and try again.',
        );
      }

      if (ride.id == null) {
        throw Exception('Cannot update ride without an ID.');
      }

      await api.updateRide(ride.id!, ride.toJson());
      ref.invalidateSelf();

      // Invalidate the individual ride cache
      ref.invalidate(trainRideByIdProvider(ride.id!));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTrainRide(int id) async {
    try {
      final api = ref.read(supabaseApiProvider);
      final currentUser = api.client.auth.currentUser;

      if (currentUser == null) {
        throw Exception(
          'You must be signed in to delete train rides. Please sign in and try again.',
        );
      }

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
List<String> rideTypeTitles(RideTypeTitlesRef ref) {
  final types = ref.watch(rideTypesNotifierProvider);
  return types.when(
    data: (list) => list
        .map((e) => (e['title'] as String?) ?? (e['value'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList(),
    loading: () => const [],
    error: (_, __) => const [],
  );
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

@riverpod
class RideTypesNotifier extends _$RideTypesNotifier {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final api = ref.read(supabaseApiProvider);
    return await api.fetchRideTypes();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> addRideType(String title, String color) async {
    try {
      final api = ref.read(supabaseApiProvider);
      await api.addRideType({
        'title': title,
        'color': color,
        'user_id': api.client.auth.currentUser?.id,
      });
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateRideType(int id, String title, String color) async {
    try {
      final api = ref.read(supabaseApiProvider);
      await api.updateRideType(id, {'title': title, 'color': color});
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteRideType(int id) async {
    try {
      final api = ref.read(supabaseApiProvider);
      await api.deleteRideType(id);
      ref.invalidateSelf();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
