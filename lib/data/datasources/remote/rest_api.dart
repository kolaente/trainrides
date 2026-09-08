import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/train_ride.dart';
import '../../models/db_lounge.dart';
import '../../models/db_lounge_visit.dart';

class RestApi {
  final HttpClient client;
  final String baseUrl;
  RestApi(this.client, {String baseUrl = ApiConstants.baseUrl})
    : baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final response = await client.get('$baseUrl/$path');
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<List<TrainRide>> fetchRides() async =>
      (await _list('rides')).map(TrainRide.fromJson).toList();

  Future<List<Map<String, dynamic>>> fetchRideTypes() => _list('ride_types');

  Future<void> addRide(Map<String, dynamic> ride) async {
    await client.post('$baseUrl/rides', body: jsonEncode(ride));
  }

  Future<void> updateRide(int id, Map<String, dynamic> patch) async {
    await client.patch('$baseUrl/rides/$id', body: jsonEncode(patch));
  }

  Future<void> deleteRide(int id) async {
    await client.delete('$baseUrl/rides/$id');
  }

  Future<void> addRideType(Map<String, dynamic> rideType) async {
    await client.post('$baseUrl/ride_types', body: jsonEncode(rideType));
  }

  Future<void> updateRideType(int id, Map<String, dynamic> patch) async {
    await client.patch('$baseUrl/ride_types/$id', body: jsonEncode(patch));
  }

  Future<void> deleteRideType(int id) async {
    await client.delete('$baseUrl/ride_types/$id');
  }

  Future<List<DbLounge>> fetchDbLounges() async =>
      (await _list('db_lounges')).map(DbLounge.fromJson).toList();

  Future<List<DbLoungeVisit>> fetchDbLoungeVisits() async =>
      (await _list('db_lounge_visits')).map(DbLoungeVisit.fromJson).toList();

  Future<int> getDbLoungeVisitCount(int loungeId) async =>
      (await getAllDbLoungeVisitCounts())[loungeId] ?? 0;

  Future<Map<int, int>> getAllDbLoungeVisitCounts() async {
    final response = await client.get('$baseUrl/db_lounge_visits/counts');
    return (jsonDecode(response.body) as Map<String, dynamic>).map(
      (key, value) => MapEntry(int.parse(key), (value as num).toInt()),
    );
  }

  Future<void> addDbLoungeVisit(int loungeId, {DateTime? visitedAt}) async {
    await client.post(
      '$baseUrl/db_lounge_visits',
      body: jsonEncode({
        'db_lounge_id': loungeId,
        'visited_at': (visitedAt ?? DateTime.now()).toUtc().toIso8601String(),
      }),
    );
  }
}
