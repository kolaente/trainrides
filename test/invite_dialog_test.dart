import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trainrides/core/network/dio_client.dart';
import 'package:trainrides/presentation/providers/network_provider.dart';
import 'package:trainrides/presentation/screens/auth/auth_screen.dart';

void main() {
  for (final claim in [false, true]) {
    testWidgets(
      claim
          ? 'claims an existing account with an invite'
          : 'creates an invited account',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final requests = <http.Request>[];
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              httpClientProvider.overrideWithValue(
                HttpClient.withClient(
                  MockClient((request) async {
                    requests.add(request);
                    return http.Response(
                      '{"error":{"message":"Example response"}}',
                      400,
                    );
                  }),
                ),
              ),
            ],
            child: const MaterialApp(home: AuthScreen()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'u@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'),
          'password123',
        );
        await tester.ensureVisible(find.text('Create account'));
        await tester.tap(find.text('Create account'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(requests, isEmpty);
        expect(find.text('Enter your invite code'), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Invite code'),
          'invitation',
        );
        if (claim) {
          await tester.tap(find.text('Claim my existing account'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(
          requests.single.url.path,
          claim ? '/auth/claim' : '/auth/signup',
        );
        expect(jsonDecode(requests.single.body), {
          'email': 'u@example.com',
          'password': 'password123',
          'invite': 'invitation',
        });
        expect(tester.takeException(), isNull);
      },
    );
  }
}
