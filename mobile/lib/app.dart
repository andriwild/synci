import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/start/splash.dart';
import 'router.dart';
import 'theme.dart';

class SynciApp extends ConsumerWidget {
  const SynciApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Synci',
    theme: buildTheme(),
    routerConfig: ref.watch(routerProvider),
    builder: (_, child) => SplashGate(child: child!),
    locale: const Locale('de', 'CH'),
    supportedLocales: const [Locale('de', 'CH')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    debugShowCheckedModeBanner: false,
  );
}
