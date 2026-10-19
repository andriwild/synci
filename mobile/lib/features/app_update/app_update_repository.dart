/// Tells whether the store has a newer version of the app and starts its installation.
abstract interface class AppUpdateRepository {
  /// Throws where the store cannot tell, e.g. for a build not installed from Google Play.
  Future<bool> isUpdateAvailable();

  /// Google Play installs the update within the app and restarts it; on iOS the App Store page opens.
  /// Only after [isUpdateAvailable] found an update. Throws if the update does not start.
  Future<void> update();
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}
