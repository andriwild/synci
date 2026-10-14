import 'dart:io';

import 'package:auth0_flutter/auth0_flutter.dart' hide ApiException;

import '../../config/env.dart';
import '../api/api_client.dart';

class AppUser {
  const AppUser({this.name, this.email, this.pictureUrl});

  factory AppUser.fromProfile(UserProfile profile) =>
      AppUser(name: profile.name, email: profile.email, pictureUrl: profile.pictureUrl);

  final String? name;
  final String? email;
  final Uri? pictureUrl;
}

class AuthService {
  AuthService({Auth0? auth0}) : _auth0 = auth0 ?? Auth0(Env.auth0Domain, Env.auth0ClientId);

  final Auth0 _auth0;

  /// Must match `auth0Scheme` in `android/app/build.gradle.kts`.
  static const _scheme = 'ch.synci.app';

  bool get isConfigured => Env.auth0ClientId.isNotEmpty;

  WebAuthentication get _webAuth => _auth0.webAuthentication(scheme: _scheme);

  Future<AppUser?> restore() async {
    if (!isConfigured) return null;
    final profile = await _auth0.credentialsManager.user();
    return profile == null ? null : AppUser.fromProfile(profile);
  }

  Future<AppUser> login({bool signup = false}) async {
    final credentials = await _webAuth.login(
      audience: Env.auth0Audience,
      parameters: signup ? const {'screen_hint': 'signup'} : const {},
      // Avoids the iOS consent dialog; logout then needs no browser
      useEphemeralSession: Platform.isIOS,
    );
    return AppUser.fromProfile(credentials.user);
  }

  Future<void> logout() async {
    if (Platform.isIOS) {
      await _auth0.credentialsManager.clearCredentials();
    } else {
      await _webAuth.logout();
    }
  }

  Future<void> clearLocalSession() => _auth0.credentialsManager.clearCredentials();

  Future<String?> accessToken() async {
    if (!isConfigured) return null;
    final credentialsManager = _auth0.credentialsManager;
    // Not hasValidCredentials: on iOS it is false once the access token expires, even with a valid refresh token
    if (await credentialsManager.user() == null) return null;
    try {
      final credentials = await credentialsManager.credentials(minTtl: 60);
      return credentials.accessToken;
    } on CredentialsManagerException catch (e) {
      if (e.isRetryable) {
        throw const ApiException('Keine Verbindung zum Server. Bitte prüfe deine Internetverbindung.');
      }
      await clearLocalSession();
      throw const SessionExpiredException();
    }
  }
}
