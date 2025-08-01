import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/train_ride.dart';

class SupabaseApi {
  final SupabaseClient client;
  SupabaseApi(this.client);

  Future<List<TrainRide>> fetchRides() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await client.from('rides').select().eq('user_id', userId);
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
        .map(
          (rows) => rows
              .map((e) => TrainRide.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> fetchRideTypes() async {
    final rows = await client.from('ride_types').select();
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
}
