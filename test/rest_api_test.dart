import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainrides/core/network/dio_client.dart';
import 'package:trainrides/data/datasources/remote/rest_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('parses worker records and SQL counts into existing models', () async {
    final api = RestApi(
      HttpClient.withClient(
        MockClient((request) async {
          final data = switch (request.url.path) {
            '/rides' => [
              {
                'id': 73,
                'from': 'Berlin',
                'to': 'Hamburg',
                'price': 19.9,
                'type_id': null,
                'date': '2025-07-03',
                'created_at': '2025-10-11T13:49:52.080Z',
                'user_id': 'u',
                'details': null,
              },
            ],
            '/ride_types' => [
              {'id': 3, 'title': 'ICE', 'color': '#ff0000'},
            ],
            '/db_lounges' => [
              {'id': 12, 'location': 'Berlin', 'anchor': 'berlin'},
            ],
            '/db_lounge_visits' => [
              {
                'id': 13,
                'db_lounge_id': 12,
                'user_id': 'u',
                'visited_at': '2025-10-11T16:52:12.135Z',
                'created_at': null,
              },
            ],
            '/db_lounge_visits/counts' => {'12': 3},
            _ => throw StateError('Unexpected path'),
          };
          return http.Response(jsonEncode(data), 200);
        }),
      ),
      baseUrl: 'https://example.com',
    );
    expect((await api.fetchRides()).single.id, 73);
    expect((await api.fetchRideTypes()).single['id'], 3);
    expect((await api.fetchDbLounges()).single.id, 12);
    expect((await api.fetchDbLoungeVisits()).single.createdAt, isNull);
    expect(await api.getAllDbLoungeVisitCounts(), {12: 3});
    expect(await api.getDbLoungeVisitCount(99), 0);
  });
  test('uses REST write verbs and accepts empty deletion responses', () async {
    final calls = <String>[];
    final api = RestApi(
      HttpClient.withClient(
        MockClient((request) async {
          calls.add('${request.method} ${request.url.path}');
          if (request.method != 'DELETE') {
            expect(jsonDecode(request.body), isA<Map>());
          }
          return http.Response('', request.method == 'DELETE' ? 204 : 201);
        }),
      ),
      baseUrl: 'https://example.com/',
    );
    await api.addRide({'from': 'Berlin'});
    await api.updateRide(73, {'price': 20});
    await api.deleteRide(73);
    await api.addRideType({'title': 'ICE'});
    await api.updateRideType(3, {'title': 'IC'});
    await api.deleteRideType(3);
    await api.addDbLoungeVisit(12);
    expect(calls, [
      'POST /rides',
      'PATCH /rides/73',
      'DELETE /rides/73',
      'POST /ride_types',
      'PATCH /ride_types/3',
      'DELETE /ride_types/3',
      'POST /db_lounge_visits',
    ]);
  });
}
