import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? error;
  final bool isLoading;
  final User? user;
  final String? token;

  AuthState({
    this.isAuthenticated = false,
    this.error,
    this.isLoading = false,
    this.user,
    this.token,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? error,
    bool? isLoading,
    User? user,
    String? token,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final response = await _authService.checkAuth();
    if (response.success) {
      state = state.copyWith(
        isAuthenticated: true,
        user: response.user,
        token: response.token,
      );
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.login(username, password);
      
      if (response.success) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          user: response.user,
          token: response.token,
        );
      } else {
        state = state.copyWith(
          error: response.error ?? 'Error desconocido',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error al iniciar sesión: $e',
        isLoading: false,
      );
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  String? getToken() {
    return _authService.getToken();
  }
}

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(prefs);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
