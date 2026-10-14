import 'package:auth0_flutter/auth0_flutter.dart' hide ApiException;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/env.dart';
import '../analytics/analytics.dart';
import '../api/api_client.dart';
import 'auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final apiClientProvider = Provider<ApiClient>((ref) {
  final authService = ref.read(authServiceProvider);
  return ApiClient(
    baseUrl: Env.backendUrl.resolve('api/'),
    accessToken: () async {
      try {
        return await authService.accessToken();
      } on SessionExpiredException {
        ref.read(authControllerProvider.notifier).sessionExpired();
        rethrow;
      }
    },
  );
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

class AuthController extends AsyncNotifier<AppUser?> {
  AuthService get _service => ref.read(authServiceProvider);

  @override
  Future<AppUser?> build() => _service.restore();

  /// Returns `false` if the user cancels.
  Future<bool> login({bool signup = false}) async {
    ref.read(analyticsProvider).event(signup ? 'signup-click' : 'login-click');
    try {
      final user = await _service.login(signup: signup);
      state = AsyncData(user);
      return true;
    } on WebAuthenticationException catch (e) {
      if (e.isUserCancelledException) return false;
      throw ApiException('Anmeldung fehlgeschlagen: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AsyncData(null);
  }

  /// Logs out right away, otherwise the backend recreates the user with the still valid token.
  Future<void> deleteAccount() async {
    await ref.read(apiClientProvider).delete('users/me');
    await _service.clearLocalSession();
    state = const AsyncData(null);
  }

  void sessionExpired() => state = const AsyncData(null);
}
