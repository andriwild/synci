import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:synci/app.dart';
import 'package:synci/core/auth/auth_controller.dart';
import 'package:synci/core/auth/auth_service.dart';
import 'package:synci/features/app_update/app_update_providers.dart';
import 'package:synci/features/organisation/organisation.dart';
import 'package:synci/features/organisation/organisation_repository.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/sport_repository.dart';
import 'package:synci/features/sync_config/sync_config.dart';
import 'package:synci/features/sync_config/sync_config_providers.dart';
import 'package:synci/features/sync_config/sync_config_repository.dart';

const _club = MyOrganisation(
  id: 'org-1',
  name: 'FC Beispiel',
  role: OrgRole.admin,
  status: OrgMemberStatus.active,
  sport: Sport(
    id: 'org-root',
    label: 'FC Beispiel',
    organisationId: 'org-1',
    subSports: [Sport(id: 'grp-1', label: '1. Mannschaft', organisationId: 'org-1')],
  ),
);

const _pending = MyOrganisation(
  id: 'org-2',
  name: 'Wartender Verein',
  role: OrgRole.member,
  status: OrgMemberStatus.pending,
  sport: Sport(id: 'org-2-root', label: 'Wartender Verein', organisationId: 'org-2'),
);

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  test('the event request uses local time without zone and omits blank fields', () {
    final request = OrganisationEventRequest(
      name: 'GV',
      sportId: 'org-root',
      startsOn: DateTime(2026, 11, 20, 19, 5),
      endsOn: DateTime(2026, 11, 20, 21),
      location: '  ',
    ).toJson();

    expect(request, {
      'name': 'GV',
      'sportId': 'org-root',
      'startsOn': '2026-11-20T19:05:00',
      'endsOn': '2026-11-20T21:00:00',
    });
    expect(
      OrganisationEventRequest(name: 'Turnier', sportId: 'x', startsOn: DateTime(2026, 6, 1)).toJson().keys,
      isNot(contains('endsOn')),
    );
  });

  test('my organisation is parsed with role, status and groups', () {
    final organisation = MyOrganisation.fromJson({
      'id': 'org-1',
      'name': 'FC Beispiel',
      'description': null,
      'role': 'ADMIN',
      'status': 'ACTIVE',
      'sport': {
        'id': 'org-root',
        'name': 'ORG_org-1',
        'label': 'FC Beispiel',
        'organisationId': 'org-1',
        'subSports': [
          {'id': 'grp-1', 'name': 'GRP_x', 'label': '1. Mannschaft', 'organisationId': 'org-1', 'subSports': []},
        ],
      },
    });

    expect(organisation.isAdmin, isTrue);
    expect(organisation.groups.single.label, '1. Mannschaft');
    expect(organisation.sport.isOrganisation, isTrue);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          authControllerProvider.overrideWith(_LoggedIn.new),
          sportRepositoryProvider.overrideWithValue(_FakeSportRepository()),
          organisationRepositoryProvider.overrideWithValue(_FakeOrganisationRepository()),
          syncConfigRepositoryProvider.overrideWithValue(_FakeSyncConfigRepository()),
          activeSyncConfigIdProvider.overrideWith(_InMemorySelection.new),
          appUpdateAvailableProvider.overrideWithValue(const AsyncData(false)),
        ],
        child: const SynciApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('active organisations come first, pending ones stay hidden', (tester) async {
    await pump(tester);

    final club = tester.getTopLeft(find.text('FC Beispiel')).dy;
    final discover = tester.getTopLeft(find.text('Organisationen entdecken')).dy;
    final basketball = tester.getTopLeft(find.text('Basketball')).dy;
    expect(club, lessThan(discover));
    expect(discover, lessThan(basketball));
    expect(find.text('Wartender Verein'), findsNothing);
  });

  testWidgets('an admin sees the toolbar and the organisation events', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('FC Beispiel öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('Event erfassen'), findsOneWidget);
    expect(find.text('Verwalten'), findsOneWidget);
    expect(find.text('Organisation'), findsWidgets);
    expect(find.text('Kommende Events'), findsOneWidget);
    expect(find.text('ganztägig'), findsOneWidget);
    expect(find.text('1. Mannschaft · Clubhaus'), findsOneWidget);
  });

  testWidgets('the organisations tab lists pending requests', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Organisationen').last);
    await tester.pumpAndSettle();

    expect(find.text('Meine Organisationen'), findsOneWidget);
    expect(find.text('Anfrage ausstehend'), findsOneWidget);
    expect(find.text('Zurückziehen'), findsOneWidget);
    expect(find.text('Löschen'), findsOneWidget);
  });
}

class _LoggedIn extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(name: 'Andri', email: 'andri@example.com');
}

class _FakeOrganisationRepository extends Fake implements OrganisationRepository {
  @override
  Future<List<MyOrganisation>> getMine() async => const [_club, _pending];
}

class _FakeSportRepository extends Fake implements SportRepository {
  @override
  Future<List<Sport>> getSports() async => const [
    Sport(
      id: 'basketball',
      label: 'Basketball',
      subSports: [Sport(id: 'nba', label: 'NBA')],
    ),
  ];

  @override
  Future<PagedResult<SportEvent>> getEvents(String sportId, {required int page, required int pageSize}) async =>
      PagedResult(
        amount: 2,
        elements: [
          SportEvent(id: 'e1', sourceId: 9, name: 'Turnier', startsOn: DateTime(2027, 5, 1), sportId: 'org-root'),
          SportEvent(
            id: 'e2',
            sourceId: 9,
            name: 'Training',
            startsOn: DateTime(2027, 5, 2, 19),
            endsOn: DateTime(2027, 5, 2, 21),
            sportId: 'grp-1',
            location: 'Clubhaus',
          ),
        ],
      );
}

class _FakeSyncConfigRepository extends Fake implements SyncConfigRepository {
  @override
  Future<List<SyncConfig>> getAll() async => const [SyncConfig(id: 'abo-1', name: 'Standard-Abo')];
}

class _InMemorySelection extends ActiveSyncConfigIdController {
  @override
  String? build() => null;

  @override
  void select(String? id) => state = id;
}
