import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_store_lookup.dart';
import 'app_store_update_repository.dart';
import 'app_update_repository.dart';
import 'play_update_repository.dart';

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>(
  (ref) => defaultTargetPlatform == TargetPlatform.android
      ? const PlayUpdateRepository()
      : AppStoreUpdateRepository(
          AppStoreLookup(
            Dio(BaseOptions(connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 10))),
            bundleId: 'ch.synci.app',
          ),
        ),
);

/// Checked once per app start (kept alive); an error, e.g. for a build not installed from a store, means no update.
final appUpdateAvailableProvider = FutureProvider<bool>(
  (ref) => ref.read(appUpdateRepositoryProvider).isUpdateAvailable(),
);
