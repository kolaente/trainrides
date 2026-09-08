import 'dart:convert';
import 'dart:io' show HttpOverrides;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainrides/core/errors/exceptions.dart';
import 'package:trainrides/core/network/dio_client.dart';
import 'package:trainrides/data/datasources/remote/rest_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'claims the imported account and reads real D1 data through Flutter',
    () async {
      final previousOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = previousOverrides);
      SharedPreferences.setMockInitialValues({});
      final client = HttpClient();
      addTearDown(client.dispose);
      const baseUrl = 'http://127.0.0.1:8787';
      const credentials = {
        'email': 'trainrides@kolaente.de',
        'password': 'local-migration-test-password',
        'invite': 'local-development-invite',
      };
      try {
        await client.post('$baseUrl/auth/claim', body: jsonEncode(credentials));
      } on ApiException catch (error) {
        if (error.statusCode != 409) rethrow;
      }
      final login = await client.post(
        '$baseUrl/auth/login',
        body: jsonEncode(credentials),
      );
      final session = jsonDecode(login.body);
      expect(session['user']['id'], '6a14f200-33b0-4820-90f3-9c09f6a66e0a');
      await client.setAuthToken(session['token'] as String);
      final api = RestApi(client, baseUrl: baseUrl);
      final rides = await api.fetchRides();
      expect(rides.length, 73);
      expect(
        rides.every((ride) => ride.userId == session['user']['id']),
        isTrue,
      );
      expect((await api.fetchRideTypes()).length, 8);
      expect((await api.fetchDbLounges()).length, 13);
      expect((await api.fetchDbLoungeVisits()).length, 14);
      expect(
        (await api.getAllDbLoungeVisitCounts()).values.reduce((a, b) => a + b),
        14,
      );
      await client.post('$baseUrl/auth/logout', body: '{}');
      await expectLater(api.fetchRides(), throwsA(isA<AuthException>()));
      await client.clearAuthToken();
    },
    skip: !const bool.fromEnvironment('RUN_WORKER_SMOKE'),
  );
}
