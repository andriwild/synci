import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const activeSyncConfigKey = 'activeSyncConfigId';

const preferenceKeys = {activeSyncConfigKey};

final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);
