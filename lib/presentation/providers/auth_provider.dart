import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/remote/baserow_api.dart';

part 'auth_provider.g.dart';

enum AuthStatus { unauthenticated, authenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? error;

  const AuthState({required this.status, this.token, this.error});

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      token = null,
      error = null;

  const AuthState.authenticated(String token)
    : status = AuthStatus.authenticated,
      token = token,
      error = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      token = null,
      error = null;

  const AuthState.error(String error)
    : status = AuthStatus.error,
      token = null,
      error = error;

  AuthState copyWith({AuthStatus? status, String? token, String? error}) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && token != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    final token = await _getStoredToken();
    if (token != null) {
      await HttpClient().setAuthToken(token);

      final isValid = await _validateToken(token);
      if (isValid) {
        await _loadFields();
        return AuthState.authenticated(token);
      } else {
        await _clearStoredToken();
        return const AuthState.unauthenticated();
      }
    }
    return const AuthState.unauthenticated();
  }

  Future<void> authenticate(String token) async {
    state = const AsyncValue.loading();

    try {
      if (token.trim().isEmpty) {
        throw const ValidationException('Token cannot be empty');
      }

      final isValid = await _validateToken(token);
      if (!isValid) {
        throw const AuthException('Invalid token');
      }

      await HttpClient().setAuthToken(token);
      await _storeToken(token);
      await _loadFields();

      state = AsyncValue.data(AuthState.authenticated(token));
    } catch (e) {
      String errorMessage = 'Authentication failed';
      if (e is AppException) {
        errorMessage = e.message;
      }
      state = AsyncValue.data(AuthState.error(errorMessage));
    }
  }

  Future<void> logout() async {
    await _clearStoredToken();
    await HttpClient().clearAuthToken();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }

  Future<bool> _validateToken(String token) async {
    try {
      final client = HttpClient();
      await client.setAuthToken(token);

      final response = await client.get(ApiConstants.baseApiUrl);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> _loadFields() async {
    try {
      await BaserowApi().loadFields();
    } catch (e) {
      // Don't fail authentication if field loading fails
    }
  }
}
