import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:synci/app.dart';
import 'package:synci/core/auth/auth_controller.dart';
import 'package:synci/core/auth/auth_service.dart';
import 'package:synci/features/app_update/app_update_providers.dart';
import 'package:synci/features/onboarding/onboarding_providers.dart';
import 'package:synci/features/organisation/organisation.dart';
import 'package:synci/features/organisation/organisation_repository.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/sport_repository.dart';
import 'package:synci/features/sync_config/abo_badge.dart';
import 'package:synci/features/sync_config/sync_config.dart';
import 'package:synci/features/sync_config/sync_config_repository.dart';

import 'helpers/phone_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  late _FakeSyncConfigRepository syncConfigs;

  Future<void> pumpLoggedIn(WidgetTester tester, {bool twoAbos = false}) async {
    usePhoneScreen(tester);
    syncConfigs = _FakeSyncConfigRepository([
      _standard,
      if (twoAbos) const SyncConfig(id: 'abo-2', name: 'Ferien-Abo'),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          authControllerProvider.overrideWith(_LoggedIn.new),
          sportRepositoryProvider.overrideWithValue(_FakeSportRepository()),
          organisationRepositoryProvider.overrideWithValue(_NoOrganisations()),
          syncConfigRepositoryProvider.overrideWithValue(syncConfigs),
          appUpdateAvailableProvider.overrideWithValue(const AsyncData(false)),
          onboardingSeenProvider.overrideWith(_OnboardingSeen.new),
        ],
        child: const SynciApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openNba(WidgetTester tester) async {
    await scrollToAndTap(tester, 'Basketball');
    await tester.tap(find.byTooltip('NBA öffnen'));
    await tester.pumpAndSettle();
  }

  Finder aboOption(String name) => find.widgetWithText(CheckboxListTile, name);

  testWidgets('Mit einem Abo speichert ein Tipp das Team direkt im ganzen Abo', (tester) async {
    await pumpLoggedIn(tester);
    await openNba(tester);

    await tester.tap(find.byTooltip('Team hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.text('In welchen Abos?'), findsNothing);
    expect(syncConfigs.lastUpdate?.toRequestJson(), {
      'id': 'abo-1',
      'name': 'Standard-Abo',
      'sports': ['basketball'],
      'teams': [
        {'id': '8678', 'sourceId': 3},
      ],
      'events': [],
      'matchups': [],
    });
    expect(find.text('Atlanta Hawks hinzugefügt'), findsOneWidget);
    expect(find.byTooltip('Team hinzufügen'), findsNothing, reason: 'Team ist jetzt als "im Abo" markiert');
  });

  testWidgets('Ein zweiter Tipp nimmt das Team wieder aus dem Abo', (tester) async {
    await pumpLoggedIn(tester);
    await openNba(tester);
    await tester.tap(find.byTooltip('Team hinzufügen'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Team entfernen'));
    await tester.pumpAndSettle();

    expect(syncConfigs.lastUpdate?.teams, isEmpty);
    expect(find.text('Atlanta Hawks entfernt'), findsOneWidget);
    expect(find.byTooltip('Team hinzufügen'), findsOneWidget);
  });

  testWidgets('Mit mehreren Abos wählt man im Sheet, in welche Abos das Team kommt', (tester) async {
    await pumpLoggedIn(tester, twoAbos: true);
    await openNba(tester);

    await tester.tap(find.byTooltip('Team hinzufügen'));
    await tester.pumpAndSettle();
    expect(find.text('In welchen Abos?'), findsOneWidget);

    await tester.tap(aboOption('Ferien-Abo'));
    await tester.pumpAndSettle();
    expect(syncConfigs.lastUpdate?.id, 'abo-2');
    expect(syncConfigs.lastUpdate?.teams.single.name, 'Atlanta Hawks');

    await tester.tap(aboOption('Standard-Abo'));
    await tester.pumpAndSettle();
    expect(syncConfigs.lastUpdate?.id, 'abo-1');
    expect(syncConfigs.lastUpdate?.teams.single.name, 'Atlanta Hawks');

    await tester.tap(aboOption('Ferien-Abo'));
    await tester.pumpAndSettle();
    expect(syncConfigs.lastUpdate?.id, 'abo-2');
    expect(syncConfigs.lastUpdate?.teams, isEmpty);

    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Abos für Team wählen'), findsOneWidget);
  });

  testWidgets('Ein neues Abo aus dem Sheet bekommt das Team gleich dazu', (tester) async {
    await pumpLoggedIn(tester, twoAbos: true);
    await openNba(tester);
    await tester.tap(find.byTooltip('Team hinzufügen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Neues Abo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Playoffs');
    await tester.tap(find.text('Erstellen'));
    await tester.pumpAndSettle();

    expect(syncConfigs.lastUpdate?.name, 'Playoffs');
    expect(syncConfigs.lastUpdate?.teams.single.name, 'Atlanta Hawks');
    expect(tester.widget<CheckboxListTile>(aboOption('Playoffs')).value, isTrue);
  });

  testWidgets('Die Kachel einer Sportart zeigt, wie viel davon im Abo ist', (tester) async {
    await pumpLoggedIn(tester);

    final badge = find.descendant(of: find.byType(AboBadge), matching: find.text('1'));
    expect(badge, findsOneWidget, reason: 'Basketball ist im Standard-Abo');
  });

  testWidgets('Ein einzelnes Abo ist in Meine Abos gleich aufgeklappt', (tester) async {
    await pumpLoggedIn(tester);

    await tester.tap(find.text('Meine Abos'));
    await tester.pumpAndSettle();

    expect(find.text('Basketball'), findsOneWidget);
    expect(find.text('Zum Kalender hinzufügen'), findsOneWidget);
  });

  testWidgets('Mehrere Abos sind zugeklappt, aufgeklappt zeigt eines den Inhalt und den Kalender', (tester) async {
    await pumpLoggedIn(tester, twoAbos: true);

    await tester.tap(find.text('Meine Abos'));
    await tester.pumpAndSettle();
    expect(find.text('1 Eintrag · Basketball'), findsOneWidget, reason: 'zugeklappt mit Vorschau');
    expect(find.text('Leer'), findsOneWidget);
    expect(find.text('Zum Kalender hinzufügen'), findsNothing);
    expect(find.text('Aktivieren'), findsNothing);

    await tester.tap(find.text('Standard-Abo'));
    await tester.pumpAndSettle();
    expect(find.text('Basketball'), findsOneWidget);

    await tester.tap(find.text('Zum Kalender hinzufügen'));
    await tester.pumpAndSettle();
    expect(find.text('Kalender hinzufügen'), findsOneWidget);
    expect(find.text('Weitere Optionen'), findsOneWidget);
  });
}

const _standard = SyncConfig(
  id: 'abo-1',
  name: 'Standard-Abo',
  sports: [Sport(id: 'basketball', label: 'Basketball', rootSport: 'Basketball')],
);

class _OnboardingSeen extends OnboardingSeenController {
  @override
  bool build() => true;
}

class _LoggedIn extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(name: 'Test', email: 'test@synci.ch');
}

class _FakeSyncConfigRepository implements SyncConfigRepository {
  _FakeSyncConfigRepository(this._configs);

  List<SyncConfig> _configs;
  SyncConfig? lastUpdate;

  @override
  Future<List<SyncConfig>> getAll() async => _configs;

  @override
  Future<SyncConfig> update(SyncConfig config) async {
    lastUpdate = config;
    _configs = [for (final c in _configs) c.id == config.id ? config : c];
    return config;
  }

  @override
  Future<SyncConfig> create(String name) async {
    final created = SyncConfig(id: 'neu', name: name);
    _configs = [..._configs, created];
    return created;
  }

  @override
  Future<void> delete(String id) async {}
}

class _FakeSportRepository implements SportRepository {
  @override
  Future<List<Sport>> getSports() async => const [
    Sport(
      id: 'basketball',
      label: 'Basketball',
      subSports: [Sport(id: 'nba', label: 'NBA')],
    ),
  ];

  @override
  Future<PagedResult<Team>> getTeams(
    String sportId, {
    required int page,
    required int pageSize,
    String search = '',
  }) async => const PagedResult(
    amount: 1,
    elements: [Team(id: '8678', sourceId: 3, name: 'Atlanta Hawks', gender: 'MAN')],
  );

  @override
  Future<PagedResult<SportEvent>> getEvents(String sportId, {required int page, required int pageSize}) async =>
      const PagedResult(amount: 0, elements: []);
}

class _NoOrganisations extends Fake implements OrganisationRepository {
  @override
  Future<List<MyOrganisation>> getMine() async => const [];
}
