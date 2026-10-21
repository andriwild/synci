import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/preferences.dart';

/// Whether the intro story has been shown; it opens on the first start.
final onboardingSeenProvider = NotifierProvider<OnboardingSeenController, bool>(OnboardingSeenController.new);

class OnboardingSeenController extends Notifier<bool> {
  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(onboardingSeenKey) ?? false;

  void markSeen() {
    ref.read(sharedPreferencesProvider).setBool(onboardingSeenKey, true);
    state = true;
  }
}
