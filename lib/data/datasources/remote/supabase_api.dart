import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/train_ride.dart';
import '../../models/db_lounge.dart';
import '../../models/db_lounge_visit.dart';

class SupabaseApi {
  final SupabaseClient client;
  SupabaseApi(this.client);

  Future<List<TrainRide>> fetchRides() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await client
        .from('rides')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    final list = rows.cast<Map<String, dynamic>>();
    return list.map((e) => TrainRide.fromJson(e)).toList();
  }

  Stream<List<TrainRide>> ridesStream() {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return client
        .from('rides')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((rows) => rows.map((e) => TrainRide.fromJson(e)).toList());
  }

  Future<List<Map<String, dynamic>>> fetchRideTypes() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await client.from('ride_types').select().eq('user_id', userId);
    return rows.cast<Map<String, dynamic>>();
  }

  Future<void> addRide(Map<String, dynamic> ride) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Please sign in to add rides.');
    }

    ride['user_id'] = userId;
    await client.from('rides').insert(ride).select();
  }

  Future<void> updateRide(int id, Map<String, dynamic> patch) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(
        'User not authenticated. Please sign in to update rides.',
      );
    }

    // Remove user_id and id from patch to prevent ownership change attempts
    final updatePatch = Map<String, dynamic>.from(patch);
    updatePatch.remove('user_id');
    updatePatch.remove('id');

    await client
        .from('rides')
        .update(updatePatch)
        .eq('id', id)
        .eq('user_id', userId)
        .select();
  }

  Future<void> deleteRide(int id) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(
        'User not authenticated. Please sign in to delete rides.',
      );
    }

    await client.from('rides').delete().eq('id', id).eq('user_id', userId);
  }

  Future<void> addRideType(Map<String, dynamic> rideType) async {
    await client.from('ride_types').insert(rideType);
  }

  Future<void> updateRideType(int id, Map<String, dynamic> patch) async {
    await client.from('ride_types').update(patch).eq('id', id);
  }

  Future<void> deleteRideType(int id) async {
    await client.from('ride_types').delete().eq('id', id);
  }

  // DB Lounge methods
  Future<List<DbLounge>> fetchDbLounges() async {
    final rows = await client
        .from('db_lounges')
        .select()
        .order('location', ascending: true);
    final list = rows.cast<Map<String, dynamic>>();
    return list.map((e) => DbLounge.fromJson(e)).toList();
  }

  Future<List<DbLoungeVisit>> fetchDbLoungeVisits() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await client
        .from('db_lounge_visits')
        .select()
        .eq('user_id', userId)
        .order('visited_at', ascending: false);
    final list = rows.cast<Map<String, dynamic>>();
    return list.map((e) => DbLoungeVisit.fromJson(e)).toList();
  }

  Future<int> getDbLoungeVisitCount(int loungeId) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await client
        .from('db_lounge_visits')
        .select('id')
        .eq('user_id', userId)
        .eq('db_lounge_id', loungeId);

    return response.length;
  }

  Future<Map<int, int>> getAllDbLoungeVisitCounts() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return {};

    final response = await client
        .from('db_lounge_visits')
        .select('db_lounge_id')
        .eq('user_id', userId);

    final Map<int, int> counts = {};
    for (final row in response) {
      final loungeId = row['db_lounge_id'] as int;
      counts[loungeId] = (counts[loungeId] ?? 0) + 1;
    }

    return counts;
  }

  Future<void> addDbLoungeVisit(int loungeId, {DateTime? visitedAt}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Please sign in to add visits.');
    }

    await client.from('db_lounge_visits').insert({
      'db_lounge_id': loungeId,
      'user_id': userId,
      'visited_at': (visitedAt ?? DateTime.now()).toIso8601String(),
    });
  }
}
