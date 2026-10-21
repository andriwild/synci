import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const activeSyncConfigKey = 'activeSyncConfigId';
const onboardingSeenKey = 'onboardingSeen';

const preferenceKeys = {activeSyncConfigKey, onboardingSeenKey};

final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);
