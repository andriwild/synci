import 'dart:io';

abstract final class Env {
  static const _backendUrl = String.fromEnvironment('BACKEND_URL', defaultValue: 'https://synci.ch/');
  static const auth0Domain = String.fromEnvironment('AUTH0_DOMAIN', defaultValue: 'account.synci.ch');
  static const auth0ClientId = String.fromEnvironment('AUTH0_CLIENT_ID');
  static const auth0Audience = String.fromEnvironment('AUTH0_AUDIENCE', defaultValue: 'https://synci.ch/api');
  static const umamiUrl = String.fromEnvironment('UMAMI_URL');
  static const umamiWebsiteId = String.fromEnvironment('UMAMI_WEBSITE_ID');

  /// On the Android emulator, `localhost` is mapped to the host machine (`10.0.2.2`).
  static Uri get backendUrl {
    final uri = Uri.parse(_backendUrl);
    if (Platform.isAndroid && uri.host == 'localhost') return uri.replace(host: '10.0.2.2');
    return uri;
  }
}
