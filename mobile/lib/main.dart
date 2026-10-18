import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/preferences.dart';

Future<void> main() async {
  await runSynci();
}

/// [overrides] replace providers, e.g. with demo data for store screenshots.
Future<ProviderContainer> runSynci({List<Override> overrides = const []}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_CH');
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Montserrat'], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  final preferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: preferenceKeys),
  );

  final container = ProviderContainer(
    // Screens show errors with a retry button instead
    retry: (_, _) => null,
    overrides: [sharedPreferencesProvider.overrideWithValue(preferences), ...overrides],
  );
  runApp(UncontrolledProviderScope(container: container, child: const SynciApp()));
  return container;
}
