import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_store_lookup.dart';
import 'app_update_repository.dart';
import 'version_order.dart';

/// iOS apps cannot install their own update, so this compares the App Store version with the installed one
/// and opens the store page.
class AppStoreUpdateRepository implements AppUpdateRepository {
  AppStoreUpdateRepository(this._lookup, {this._installedVersion = _packageVersion, this._open = _openExternally});

  final AppStoreLookup _lookup;
  final Future<String> Function() _installedVersion;
  final Future<bool> Function(Uri page) _open;

  Uri? _storePage;

  @override
  Future<bool> isUpdateAvailable() async {
    final listing = await _lookup.fetch();
    final installed = await _installedVersion();
    _storePage = listing != null && isLaterVersion(listing.version, installed) ? listing.page : null;
    return _storePage != null;
  }

  @override
  Future<void> update() async {
    final page = _storePage;
    if (page == null || !await _open(page)) throw const AppUpdateException('App Store page did not open');
  }
}

Future<String> _packageVersion() async => (await PackageInfo.fromPlatform()).version;

Future<bool> _openExternally(Uri page) => launchUrl(page, mode: LaunchMode.externalApplication);
