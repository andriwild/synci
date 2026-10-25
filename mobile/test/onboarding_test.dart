import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:synci/app.dart';
import 'package:synci/core/widgets/synci_logo.dart';
import 'package:synci/features/app_update/app_update_providers.dart';
import 'package:synci/features/onboarding/onboarding_providers.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/sport_repository.dart';
import 'package:synci/features/start/splash.dart';
import 'package:synci/features/sync_config/sync_config_providers.dart';

import 'helpers/phone_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  Future<void> pumpApp(WidgetTester tester, {bool seen = false, Future<List<Sport>>? sports}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sportRepositoryProvider.overrideWithValue(_FakeSportRepository(sports)),
          activeSyncConfigIdProvider.overrideWith(_NoSelection.new),
          appUpdateAvailableProvider.overrideWithValue(const AsyncData(false)),
          onboardingSeenProvider.overrideWith(() => _InMemoryOnboarding(seen)),
        ],
        child: const SynciApp(),
      ),
    );
  }

  // The intro logo keeps turning, so pumpAndSettle would never return
  Future<void> wait(WidgetTester tester, [Duration duration = const Duration(seconds: 2)]) async {
    for (var elapsed = Duration.zero; elapsed < duration; elapsed += const Duration(milliseconds: 100)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  bool seen(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(SynciApp))).read(onboardingSeenProvider);

  final splashLogo = find.byWidgetPredicate((w) => w is SynciLogo && w.size == splashLogoSize);

  group('Splash', () {
    testWidgets('dreht das Sync-Zeichen, bis die Daten da sind', (tester) async {
      final sports = Completer<List<Sport>>();
      await pumpApp(tester, seen: true, sports: sports.future);

      await wait(tester, const Duration(milliseconds: 2500));
      expect(splashLogo, findsOneWidget);
      expect(find.text('Sportarten'), findsNothing);

      sports.complete(const [Sport(id: 'basketball', label: 'Basketball')]);
      await wait(tester);
      expect(splashLogo, findsNothing);
      expect(find.text('Sportarten'), findsOneWidget);
    });

    testWidgets('hängt das Laden, geht es nach spätestens vier Sekunden weiter', (tester) async {
      await pumpApp(tester, seen: true, sports: Completer<List<Sport>>().future);

      await wait(tester, const Duration(seconds: 3));
      expect(splashLogo, findsOneWidget);

      await wait(tester, const Duration(seconds: 3));
      expect(splashLogo, findsNothing);
      expect(find.text('Sportarten'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Story', () {
    testWidgets('erklärt die App beim ersten Start', (tester) async {
      await pumpApp(tester);
      await wait(tester);

      expect(find.text('Willkommen bei Synci'), findsOneWidget);
      expect(find.text('Überspringen'), findsOneWidget);
      expect(find.text('Start'), findsNothing, reason: 'ohne Tabs');

      await tester.tap(find.text('Weiter'));
      await wait(tester, const Duration(milliseconds: 500));
      expect(find.text('Wähle, was dich interessiert'), findsOneWidget);
      expect(find.text('Eishockey'), findsOneWidget);

      // Advances by itself
      await wait(tester, const Duration(seconds: 7));
      expect(find.text('Sammle alles in einem Abo'), findsOneWidget);
      expect(find.text('ZL'), findsOneWidget, reason: 'Teams ohne Logo zeigen ihre Initialen');

      // A tap on the left goes back
      await tester.tapAt(const Offset(30, 400));
      await wait(tester, const Duration(milliseconds: 500));
      expect(find.text('Wähle, was dich interessiert'), findsOneWidget);

      // Holding pauses
      final hold = await tester.startGesture(const Offset(200, 400));
      await wait(tester, const Duration(seconds: 10));
      expect(find.text('Wähle, was dich interessiert'), findsOneWidget);
      await hold.up();

      await tester.tap(find.text('Überspringen'));
      await wait(tester);
      expect(find.text('Sportarten'), findsOneWidget);
      expect(seen(tester), isTrue);
    });

    testWidgets('endet mit "Los geht\'s"', (tester) async {
      await pumpApp(tester);
      await wait(tester);

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Weiter'));
        await wait(tester, const Duration(milliseconds: 500));
      }
      expect(find.text('Auch für deinen Verein'), findsOneWidget);
      expect(find.text('Weiter'), findsNothing);

      await tester.tap(find.byTooltip('Zurück'));
      await wait(tester, const Duration(milliseconds: 500));
      expect(find.text('Einmal abonnieren, immer aktuell'), findsOneWidget);
      await tester.tap(find.byTooltip('Zurück'));
      await wait(tester, const Duration(milliseconds: 500));
      expect(find.text('Sammle alles in einem Abo'), findsOneWidget);
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('Weiter'));
        await wait(tester, const Duration(milliseconds: 500));
      }

      await tester.tap(find.text("Los geht's"));
      await wait(tester);
      expect(find.text('Sportarten'), findsOneWidget);
      expect(seen(tester), isTrue);
    });

    testWidgets('kommt nach dem ersten Mal nicht wieder, lässt sich im Konto aber öffnen', (tester) async {
      await pumpApp(tester, seen: true);
      await wait(tester);
      expect(find.text('Überspringen'), findsNothing);

      await tester.tap(find.text('Konto'));
      await wait(tester, const Duration(milliseconds: 500));
      await tester.tap(find.text('So funktioniert Synci'));
      // the page transition has to finish before the tabs are offstage
      await wait(tester, const Duration(seconds: 1));
      expect(find.text('Willkommen bei Synci'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing, reason: 'die Story nutzt den ganzen Bildschirm');

      await tester.tap(find.text('Überspringen'));
      await wait(tester, const Duration(milliseconds: 500));
      expect(find.text('So funktioniert Synci'), findsOneWidget, reason: 'zurück im Konto');
    });
  });
}

class _InMemoryOnboarding extends OnboardingSeenController {
  _InMemoryOnboarding(this._seen);

  final bool _seen;

  @override
  bool build() => _seen;

  @override
  void markSeen() => state = true;
}

class _NoSelection extends ActiveSyncConfigIdController {
  @override
  String? build() => null;
}

class _FakeSportRepository implements SportRepository {
  _FakeSportRepository(this._sports);

  final Future<List<Sport>>? _sports;

  @override
  Future<List<Sport>> getSports() =>
      _sports ??
      Future.value(const [
        Sport(
          id: 'basketball',
          label: 'Basketball',
          subSports: [Sport(id: 'nba', label: 'NBA')],
        ),
      ]);

  @override
  Future<PagedResult<Team>> getTeams(
    String sportId, {
    required int page,
    required int pageSize,
    String search = '',
  }) async => const PagedResult(amount: 0, elements: []);

  @override
  Future<PagedResult<SportEvent>> getEvents(String sportId, {required int page, required int pageSize}) async =>
      const PagedResult(amount: 0, elements: []);
}
