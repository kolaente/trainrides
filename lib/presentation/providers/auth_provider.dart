import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

enum AuthStatus { unauthenticated, authenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? error;
  final Session? session;

  const AuthState({required this.status, this.token, this.error, this.session});

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      token = null,
      session = null,
      error = null;

  const AuthState.authenticated(this.session)
    : status = AuthStatus.authenticated,
      token = null,
      error = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      token = null,
      session = null,
      error = null;

  const AuthState.error(this.error)
    : status = AuthStatus.error,
      token = null,
      session = null;

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? error,
    Session? session,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      error: error ?? this.error,
      session: session ?? this.session,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    try {
      final initial = Supabase.instance.client.auth.currentSession;
      if (initial != null) {
        return AuthState.authenticated(initial);
      }
    } catch (_) {}
    return const AuthState.unauthenticated();
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final session = res.session;
      if (session != null) {
        state = AsyncValue.data(AuthState.authenticated(session));
      } else {
        state = const AsyncValue.data(AuthState.unauthenticated());
      }
    } catch (e) {
      state = AsyncValue.data(AuthState.error(e.toString()));
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = res.session;
      if (session != null) {
        state = AsyncValue.data(AuthState.authenticated(session));
      } else {
        state = const AsyncValue.data(AuthState.unauthenticated());
      }
    } catch (e) {
      state = AsyncValue.data(AuthState.error(e.toString()));
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }

  void listenAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AsyncValue.data(AuthState.authenticated(session));
      } else {
        state = const AsyncValue.data(AuthState.unauthenticated());
      }
    });
  }
}
