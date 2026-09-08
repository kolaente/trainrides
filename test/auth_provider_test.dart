import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainrides/core/network/dio_client.dart';
import 'package:trainrides/presentation/providers/network_provider.dart';
import 'package:trainrides/presentation/providers/auth_provider.dart';
import 'package:trainrides/presentation/providers/train_rides_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  ProviderContainer containerFor(
    Future<http.Response> Function(http.Request) handler,
  ) {
    final container = ProviderContainer(
      overrides: [
        httpClientProvider.overrideWithValue(
          HttpClient.withClient(MockClient(handler)),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('restores persisted sessions using auth/me', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'saved'});
    final container = containerFor((request) async {
      expect(request.url.path, '/auth/me');
      expect(request.headers['authorization'], 'Bearer saved');
      return http.Response(
        jsonEncode({
          'user': {'id': 'u', 'email': 'u@example.com'},
        }),
        200,
      );
    });
    final state = await container.read(authNotifierProvider.future);
    expect(state.isAuthenticated, isTrue);
    expect(state.user?.id, 'u');
  });
  test(
    'clears rejected tokens but keeps tokens after network failures',
    () async {
      for (final status in [401, 500]) {
        SharedPreferences.setMockInitialValues({'auth_token': 'saved'});
        final container = containerFor(
          (_) async => http.Response('{"error":{"message":"Failed"}}', status),
        );
        final state = await container.read(authNotifierProvider.future);
        expect(state.isAuthenticated, isFalse);
        expect(
          (await SharedPreferences.getInstance()).getString('auth_token'),
          status == 401 ? null : 'saved',
        );
      }
    },
  );
  test(
    'signs in, signs up and claims using the expected endpoints and persists tokens',
    () async {
      final calls = <String>[];
      final container = containerFor((request) async {
        calls.add(request.url.path);
        final body = jsonDecode(request.body) as Map;
        expect(body['email'], 'u@example.com');
        if (request.url.path != '/auth/login')
          expect(body['invite'], 'invitation');
        return http.Response(
          jsonEncode({
            'token': 'new-token',
            'expiresAt': '2026-10-08T00:00:00Z',
            'user': {'id': 'u', 'email': body['email']},
          }),
          200,
        );
      });
      await container.read(authNotifierProvider.future);
      final auth = container.read(authNotifierProvider.notifier);
      await auth.signIn('u@example.com', 'password');
      await auth.signUp('u@example.com', 'password', invite: 'invitation');
      await auth.claim('u@example.com', 'password', invite: 'invitation');
      expect(calls, ['/auth/login', '/auth/signup', '/auth/claim']);
      expect(
        (await SharedPreferences.getInstance()).getString('auth_token'),
        'new-token',
      );
    },
  );
  test('logs out locally even if the server is unavailable', () async {
    SharedPreferences.setMockInitialValues({'auth_token': 'saved'});
    final container = containerFor(
      (request) async => request.url.path == '/auth/me'
          ? http.Response('{"user":{"id":"u","email":"u@example.com"}}', 200)
          : http.Response('{}', 500),
    );
    await container.read(authNotifierProvider.future);
    await container.read(authNotifierProvider.notifier).logout();
    expect(
      container.read(authNotifierProvider).value!.isAuthenticated,
      isFalse,
    );
    expect(
      (await SharedPreferences.getInstance()).getString('auth_token'),
      isNull,
    );
  });
  test('refreshes user-scoped caches when the account changes', () async {
    final container = containerFor((request) async {
      if (request.url.path == '/auth/login') {
        final email = jsonDecode(request.body)['email'];
        return http.Response(
          jsonEncode({
            'token': email,
            'user': {'id': email, 'email': email},
          }),
          200,
        );
      }
      final owner = request.headers['authorization']!.substring(7);
      return http.Response(
        jsonEncode([
          {
            'id': 1,
            'from': owner,
            'to': 'Berlin',
            'price': 0,
            'date': '2026-09-08',
            'created_at': '2026-09-08T00:00:00Z',
            'user_id': owner,
          },
        ]),
        200,
      );
    });
    final subscription = container.listen(
      trainRidesNotifierProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    await container.read(authNotifierProvider.future);
    final auth = container.read(authNotifierProvider.notifier);
    await auth.signIn('a@example.com', 'password');
    expect(
      (await container.read(trainRidesNotifierProvider.future)).single.userId,
      'a@example.com',
    );
    await auth.signIn('b@example.com', 'password');
    expect(
      (await container.read(trainRidesNotifierProvider.future)).single.userId,
      'b@example.com',
    );
  });
}
