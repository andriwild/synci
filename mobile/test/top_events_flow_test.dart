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
import 'package:synci/features/sport/team_logo.dart';
import 'package:synci/features/sport/top_event_repository.dart';
import 'package:synci/features/sync_config/sync_config.dart';
import 'package:synci/features/sync_config/sync_config_providers.dart';
import 'package:synci/features/sync_config/sync_config_repository.dart';

import 'helpers/phone_screen.dart';

const _real = Team(id: '5477', sourceId: 3, name: 'Real Madrid', gender: 'MAN');
const _barca = Team(id: '5469', sourceId: 3, name: 'FC Barcelona', gender: 'MAN');

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  late _FakeSyncConfigRepository syncConfigs;

  Future<void> pumpLoggedIn(WidgetTester tester, {List<Matchup> matchups = const []}) async {
    usePhoneScreen(tester);
    syncConfigs = _FakeSyncConfigRepository(matchups);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          authControllerProvider.overrideWith(_LoggedIn.new),
          sportRepositoryProvider.overrideWithValue(_FakeSportRepository()),
          topEventRepositoryProvider.overrideWithValue(_FakeTopEventRepository()),
          organisationRepositoryProvider.overrideWithValue(_NoOrganisations()),
          syncConfigRepositoryProvider.overrideWithValue(syncConfigs),
          activeSyncConfigIdProvider.overrideWith(_InMemorySelection.new),
          appUpdateAvailableProvider.overrideWithValue(const AsyncData(false)),
          onboardingSeenProvider.overrideWith(_OnboardingSeen.new),
        ],
        child: const SynciApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// A game shown as "Home (logo) : (logo) Away".
  Finder gameTitle(String home, String away) => find.byWidgetPredicate(
    (widget) => widget is GameTitle && widget.teams.map((t) => t.name).join(':') == '$home:$away',
  );

  Future<void> pickTeam(WidgetTester tester, String field, String team) async {
    await tester.tap(find.ancestor(of: find.text(field), matching: find.byType(InputDecorator)));
    await tester.pumpAndSettle();
    // the picker is the topmost sheet; the page below may show the team too
    await tester.tap(find.text(team).last);
    await tester.pumpAndSettle();
  }

  Future<void> openCreateSheet(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Hinzufügen'));
    await tester.pumpAndSettle();
  }

  void expectLabelAboveHint(WidgetTester tester, String field, String hint) {
    final decorator = find.ancestor(of: find.text(field), matching: find.byType(InputDecorator));
    final label = tester.getRect(find.text(field));
    final hintRect = tester.getRect(find.descendant(of: decorator, matching: find.text(hint)));
    expect(label.bottom, lessThanOrEqualTo(hintRect.top), reason: '$field steht über dem Hinweis, nicht darauf');
  }

  testWidgets('Top Event mit Vorschau ins Abo speichern', (tester) async {
    await pumpLoggedIn(tester);

    await scrollToAndTap(tester, 'Top Events');
    expect(find.text('0 von 20'), findsOneWidget);
    expect(find.text('Noch keine Top Events in diesem Abo.'), findsOneWidget);

    await openCreateSheet(tester);
    expect(find.text('Top Event hinzufügen'), findsOneWidget);
    expect(find.text('Ski Alpin'), findsNothing, reason: 'nur Sportarten mit Teams');
    expectLabelAboveHint(tester, 'Team 1', 'Zuerst Sportart wählen');
    await tester.tap(find.text('Sportart'));
    await tester.pumpAndSettle();
    expect(find.text('Ski Alpin'), findsNothing);
    await tester.tap(find.text('Fussball').last);
    await tester.pumpAndSettle();
    expectLabelAboveHint(tester, 'Team 2', 'Team wählen');

    await pickTeam(tester, 'Team 1', 'Real Madrid');
    await pickTeam(tester, 'Team 2', 'FC Barcelona');
    expect(find.text('1 Spiel geplant'), findsOneWidget);
    expect(gameTitle('FC Barcelona', 'Real Madrid'), findsOneWidget, reason: 'Vorschau wie eine Anzeigetafel');

    await tester.tap(find.text('Zum Abo hinzufügen'));
    await tester.pumpAndSettle();

    expect(syncConfigs.lastUpdate?.toRequestJson()['matchups'], [
      {'sourceId': 3, 'teamAId': '5477', 'teamBId': '5469'},
    ]);
    expect(find.text('Real Madrid – FC Barcelona hinzugefügt'), findsOneWidget);
    expect(find.text('1 von 20'), findsOneWidget);
    expect(gameTitle('Real Madrid', 'FC Barcelona'), findsOneWidget, reason: 'die Seite listet das neue Top Event');
    expect(find.textContaining('Nächstes Spiel: '), findsOneWidget);
  });

  testWidgets('Ein Top Event auf der Top-Events-Seite entfernen', (tester) async {
    await pumpLoggedIn(
      tester,
      matchups: const [Matchup(sourceId: 3, teamA: _real, teamB: _barca)],
    );

    await scrollToAndTap(tester, 'Top Events');
    expect(find.text('1 von 20'), findsOneWidget);
    expect(gameTitle('Real Madrid', 'FC Barcelona'), findsOneWidget);
    expect(
      find.descendant(of: gameTitle('Real Madrid', 'FC Barcelona'), matching: find.byType(TeamLogo)),
      findsNWidgets(2),
      reason: 'beide Teams mit Logo',
    );

    await tester.tap(find.byTooltip('Real Madrid – FC Barcelona entfernen'));
    await tester.pumpAndSettle();

    expect(syncConfigs.lastUpdate?.toRequestJson()['matchups'], isEmpty);
    expect(find.text('0 von 20'), findsOneWidget);
    expect(find.text('Real Madrid – FC Barcelona entfernt'), findsOneWidget);
  });

  testWidgets('Ein Top Event, das schon im Abo ist, lässt sich nicht nochmals hinzufügen', (tester) async {
    await pumpLoggedIn(
      tester,
      matchups: const [Matchup(sourceId: 3, teamA: _real, teamB: _barca)],
    );

    await scrollToAndTap(tester, 'Top Events');
    await openCreateSheet(tester);
    await tester.tap(find.text('Sportart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fussball').last);
    await tester.pumpAndSettle();
    await pickTeam(tester, 'Team 1', 'FC Barcelona');
    await pickTeam(tester, 'Team 2', 'Real Madrid');

    expect(find.text('Dieses Top Event ist schon in deinem Abo.'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Zum Abo hinzufügen')).onPressed, isNull);
  });

  testWidgets('Spiele zeigen die Logos beider Teams', (tester) async {
    await pumpLoggedIn(tester);

    await scrollToAndTap(tester, 'Fussball');
    await tester.tap(find.text('Ganze Sportart'));
    await tester.pumpAndSettle();

    final game = gameTitle('FC Barcelona', 'Real Madrid');
    expect(game, findsOneWidget);
    expect(find.descendant(of: game, matching: find.byType(TeamLogo)), findsNWidgets(2));
  });

  testWidgets('Meine Abos listet die Top Events und entfernt sie', (tester) async {
    await pumpLoggedIn(
      tester,
      matchups: const [Matchup(sourceId: 3, teamA: _real, teamB: _barca, rootSport: 'Fussball')],
    );

    await tester.tap(find.text('Meine Abos'));
    await tester.pumpAndSettle();
    expect(find.text('Top Events'), findsOneWidget);
    expect(gameTitle('Real Madrid', 'FC Barcelona'), findsOneWidget);

    await tester.tap(find.byTooltip('Entfernen'));
    await tester.pumpAndSettle();

    expect(syncConfigs.lastUpdate?.toRequestJson()['matchups'], isEmpty);
  });
}

class _OnboardingSeen extends OnboardingSeenController {
  @override
  bool build() => true;
}

class _LoggedIn extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(name: 'Test', email: 'test@synci.ch');
}

class _InMemorySelection extends ActiveSyncConfigIdController {
  @override
  String? build() => null;

  @override
  void select(String id) => state = id;
}

class _FakeSyncConfigRepository implements SyncConfigRepository {
  _FakeSyncConfigRepository(List<Matchup> matchups)
    : _config = SyncConfig(id: 'abo-1', name: 'Standard-Abo', matchups: matchups);

  SyncConfig _config;
  SyncConfig? lastUpdate;

  @override
  Future<List<SyncConfig>> getAll() async => [_config];

  @override
  Future<SyncConfig> update(SyncConfig config) async {
    lastUpdate = config;
    return _config = config;
  }

  @override
  Future<SyncConfig> create(String name) async => SyncConfig(id: 'neu', name: name);

  @override
  Future<void> delete(String id) async {}
}

class _FakeSportRepository implements SportRepository {
  @override
  Future<List<Sport>> getSports() async => const [
    Sport(id: 'top', name: topEventsName, label: 'Top Events'),
    Sport(
      id: 'soccer',
      name: 'SOCCER',
      label: 'Fussball',
      hasTeams: true,
      subSports: [Sport(id: 'laliga', name: 'SOCCER_PRIMERA_DIVISION', label: 'Primera División', hasTeams: true)],
    ),
    Sport(id: 'ski', name: 'SKI_ALPINE', label: 'Ski Alpin'),
  ];

  @override
  Future<PagedResult<Team>> getTeams(
    String sportId, {
    required int page,
    required int pageSize,
    String search = '',
  }) async => const PagedResult(amount: 2, elements: [_real, _barca]);

  @override
  Future<PagedResult<SportEvent>> getEvents(String sportId, {required int page, required int pageSize}) async =>
      PagedResult(amount: 1, elements: [_clasico]);
}

final _clasico = SportEvent(
  id: '1',
  sourceId: 3,
  name: 'FC Barcelona - Real Madrid',
  startsOn: DateTime(2026, 10, 25, 21),
  teams: const [_barca, _real],
);

class _FakeTopEventRepository implements TopEventRepository {
  @override
  Future<PagedResult<SportEvent>> getUpcomingGames(MatchupQuery query, {required int pageSize}) async =>
      PagedResult(amount: 1, elements: [_clasico]);
}

class _NoOrganisations extends Fake implements OrganisationRepository {
  @override
  Future<List<MyOrganisation>> getMine() async => const [];
}
