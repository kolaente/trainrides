import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/train_ride.dart';

class SupabaseApi {
  final SupabaseClient client;
  SupabaseApi(this.client);

  Future<List<TrainRide>> fetchRides() async {
    final rows = await client.from('rides').select();
    final list = (rows as List).cast<Map<String, dynamic>>();
    return list.map((e) => TrainRide.fromJson(e)).toList();
  }

  Stream<List<TrainRide>> ridesStream() {
    return client
        .from('rides')
        .stream(primaryKey: ['id'])
        .map(
          (rows) => rows
              .map((e) => TrainRide.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> fetchRideTypes() async {
    final rows = await client.from('ride_types').select();
    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<void> addRide(Map<String, dynamic> ride) async {
    await client.from('rides').insert(ride).select();
  }

  Future<void> updateRide(int id, Map<String, dynamic> patch) async {
    await client.from('rides').update(patch).eq('id', id).select();
  }

  Future<void> deleteRide(int id) async {
    await client.from('rides').delete().eq('id', id);
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
