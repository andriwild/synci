import 'package:in_app_update/in_app_update.dart';

import 'app_update_repository.dart';

/// Google Play in-app updates: Play downloads the new version full screen and restarts the app.
/// Only builds installed from Play can ask, others throw a `PlatformException`.
class PlayUpdateRepository implements AppUpdateRepository {
  const PlayUpdateRepository();

  @override
  Future<bool> isUpdateAvailable() async {
    final info = await InAppUpdate.checkForUpdate();
    return info.updateAvailability == UpdateAvailability.updateAvailable && info.immediateUpdateAllowed;
  }

  /// Returns normally when the user declines the update.
  @override
  Future<void> update() async {
    if (await InAppUpdate.performImmediateUpdate() == AppUpdateResult.inAppUpdateFailed) {
      throw const AppUpdateException('Play in-app update failed');
    }
  }
}
