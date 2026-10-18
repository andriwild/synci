import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:synci/app.dart';
import 'package:synci/core/auth/auth_controller.dart';
import 'package:synci/core/auth/auth_service.dart';
import 'package:synci/features/organisation/organisation.dart';
import 'package:synci/features/organisation/organisation_repository.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/sport_repository.dart';
import 'package:synci/features/sync_config/sync_config.dart';
import 'package:synci/features/sync_config/sync_config_providers.dart';
import 'package:synci/features/sync_config/sync_config_repository.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  late _FakeSyncConfigRepository syncConfigs;

  Future<void> pumpLoggedIn(WidgetTester tester) async {
    syncConfigs = _FakeSyncConfigRepository();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          authControllerProvider.overrideWith(_LoggedIn.new),
          sportRepositoryProvider.overrideWithValue(_FakeSportRepository()),
          organisationRepositoryProvider.overrideWithValue(_NoOrganisations()),
          syncConfigRepositoryProvider.overrideWithValue(syncConfigs),
          activeSyncConfigIdProvider.overrideWith(_InMemorySelection.new),
        ],
        child: const SynciApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Team hinzufügen speichert das ganze aktive Abo', (tester) async {
    await pumpLoggedIn(tester);
    expect(find.text('Standard-Abo'), findsOneWidget);

    await tester.tap(find.text('Basketball'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('NBA öffnen'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Team hinzufügen'));
    await tester.pumpAndSettle();

    expect(syncConfigs.lastUpdate?.toRequestJson(), {
      'id': 'abo-1',
      'name': 'Standard-Abo',
      'sports': ['basketball'],
      'teams': [
        {'id': '8678', 'sourceId': 3},
      ],
      'events': [],
    });
    expect(find.text('Atlanta Hawks hinzugefügt'), findsOneWidget);
    expect(find.byTooltip('Team hinzufügen'), findsNothing, reason: 'Team ist jetzt als "im Abo" markiert');
  });

  testWidgets('Meine Abos zeigt den Inhalt und öffnet das Kalender-Sheet', (tester) async {
    await pumpLoggedIn(tester);

    await tester.tap(find.text('Meine Abos'));
    await tester.pumpAndSettle();
    expect(find.text('Basketball'), findsOneWidget);
    expect(find.text('Aktiv'), findsOneWidget);

    await tester.tap(find.text('Zum Kalender hinzufügen'));
    await tester.pumpAndSettle();
    expect(find.text('Kalender hinzufügen'), findsOneWidget);
    expect(find.text('Weitere Optionen'), findsOneWidget);
  });
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
  SyncConfig _config = const SyncConfig(
    id: 'abo-1',
    name: 'Standard-Abo',
    sports: [Sport(id: 'basketball', label: 'Basketball', rootSport: 'Basketball')],
  );
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
