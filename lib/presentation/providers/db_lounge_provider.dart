import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/db_lounge.dart';
import '../../data/models/db_lounge_visit.dart';
import 'train_rides_provider.dart';

part 'db_lounge_provider.g.dart';

@riverpod
class DbLoungesNotifier extends _$DbLoungesNotifier {
  @override
  Future<List<DbLounge>> build() async {
    final api = ref.read(supabaseApiProvider);
    return await api.fetchDbLounges();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class DbLoungeVisitsNotifier extends _$DbLoungeVisitsNotifier {
  @override
  Future<List<DbLoungeVisit>> build() async {
    final api = ref.read(supabaseApiProvider);
    return await api.fetchDbLoungeVisits();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> addVisit(int loungeId, {DateTime? visitedAt}) async {
    try {
      final api = ref.read(supabaseApiProvider);
      await api.addDbLoungeVisit(loungeId, visitedAt: visitedAt);
      ref.invalidateSelf();

      // Invalidate all visit counts to refresh the UI
      ref.invalidate(dbLoungeVisitCountProvider(loungeId));
      ref.invalidate(dbLoungeVisitCountsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

@riverpod
Future<int> dbLoungeVisitCount(Ref ref, int loungeId) async {
  final api = ref.read(supabaseApiProvider);
  return await api.getDbLoungeVisitCount(loungeId);
}

@riverpod
Future<Map<int, int>> dbLoungeVisitCounts(Ref ref) async {
  final api = ref.read(supabaseApiProvider);
  return await api.getAllDbLoungeVisitCounts();
}
