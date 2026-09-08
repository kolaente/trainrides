import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainrides/core/errors/exceptions.dart';
import 'package:trainrides/core/network/dio_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('persists bearer tokens and clears them', () async {
    final client = HttpClient.withClient(
      MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer saved-token');
        return http.Response('[]', 200);
      }),
    );
    await client.setAuthToken('saved-token');
    await client.get('https://example.com/rides');
    expect(
      (await SharedPreferences.getInstance()).getString('auth_token'),
      'saved-token',
    );
    await client.clearAuthToken();
    expect(await client.getAuthToken(), isNull);
  });

  test(
    'preserves API and auth errors instead of wrapping as network errors',
    () async {
      for (final status in [400, 401, 404, 429]) {
        final client = HttpClient.withClient(
          MockClient(
            (_) async => http.Response(
              jsonEncode({
                'error': {'code': 'test_error', 'message': 'Useful message'},
              }),
              status,
            ),
          ),
        );
        for (final call in [
          () => client.get('https://example.com'),
          () => client.post('https://example.com', body: '{}'),
          () => client.put('https://example.com', body: '{}'),
          () => client.patch('https://example.com', body: '{}'),
          () => client.delete('https://example.com'),
        ]) {
          await expectLater(
            call(),
            throwsA(
              (status == 401 ? isA<AuthException>() : isA<ApiException>())
                  .having((e) => e.message, 'message', 'Useful message'),
            ),
          );
        }
      }
    },
  );
  test(
    'keeps HTTP status errors when proxies return other response shapes',
    () async {
      for (final body in [
        '<html>Rate limited</html>',
        'null',
        '[]',
        '"unavailable"',
      ]) {
        final client = HttpClient.withClient(
          MockClient((_) async => http.Response(body, 429)),
        );
        await expectLater(
          client.get('https://example.com'),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 429),
          ),
        );
      }
    },
  );
}
