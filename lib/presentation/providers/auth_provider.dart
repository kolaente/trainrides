import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import 'network_provider.dart';

part 'auth_provider.g.dart';

enum AuthStatus { unauthenticated, authenticated, loading, error }

class AuthUser {
  final String id;
  final String email;
  const AuthUser({required this.id, required this.email});
  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      AuthUser(id: json['id'] as String, email: json['email'] as String);
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      error = null;
  const AuthState.authenticated(AuthUser this.user)
    : status = AuthStatus.authenticated,
      error = null;
  const AuthState.error(String this.error)
    : status = AuthStatus.error,
      user = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  String get _authUrl =>
      '${ApiConstants.baseUrl.replaceFirst(RegExp(r'/$'), '')}/auth';

  @override
  Future<AuthState> build() async {
    final client = ref.watch(httpClientProvider);
    if (await client.getAuthToken() == null)
      return const AuthState.unauthenticated();
    try {
      final response = await client.get('$_authUrl/me');
      return AuthState.authenticated(
        AuthUser.fromJson(jsonDecode(response.body)['user']),
      );
    } on AuthException {
      await client.clearAuthToken();
      return const AuthState.unauthenticated();
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  Future<void> signUp(
    String email,
    String password, {
    required String invite,
  }) => _authenticate('signup', email, password, invite: invite);

  Future<void> claim(String email, String password, {required String invite}) =>
      _authenticate('claim', email, password, invite: invite);

  Future<void> signIn(String email, String password) =>
      _authenticate('login', email, password);

  Future<void> _authenticate(
    String action,
    String email,
    String password, {
    String? invite,
  }) async {
    final client = ref.read(httpClientProvider);
    state = const AsyncValue.loading();
    try {
      await client.clearAuthToken();
      final response = await client.post(
        '$_authUrl/$action',
        body: jsonEncode({
          'email': email,
          'password': password,
          if (invite != null) 'invite': invite,
        }),
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final user = AuthUser.fromJson(json['user'] as Map<String, dynamic>);
      await client.setAuthToken(json['token'] as String);
      state = AsyncValue.data(AuthState.authenticated(user));
    } catch (e) {
      state = AsyncValue.data(AuthState.error(e.toString()));
    }
  }

  Future<void> logout() async {
    final client = ref.read(httpClientProvider);
    try {
      await client.post('$_authUrl/logout', body: '{}');
    } on AppException {
      // Local logout must also work offline.
    } finally {
      await client.clearAuthToken();
      state = const AsyncValue.data(AuthState.unauthenticated());
    }
  }
}
