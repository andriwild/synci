import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:synci/core/api/api_client.dart';
import 'package:synci/core/auth/auth_controller.dart';
import 'package:synci/core/auth/auth_service.dart';
import 'package:synci/features/app_update/app_update_providers.dart';
import 'package:synci/features/calendar/calendar_sheet.dart';
import 'package:synci/features/onboarding/onboarding_providers.dart';
import 'package:synci/features/organisation/organisation.dart';
import 'package:synci/features/organisation/organisation_repository.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/sport_repository.dart';
import 'package:synci/features/sync_config/sync_config.dart';
import 'package:synci/features/sync_config/sync_config_repository.dart';
import 'package:synci/main.dart' as app;
import 'package:synci/router.dart';

/// Store screenshots: real sports from the configured backend, a demo user, abo and organisation.
/// Run it with `store_assets/capture.sh`, see `store_assets/README.md`.
Future<void> main() async {
  final container = await app.runSynci(
    overrides: [
      authControllerProvider.overrideWith(_DemoUser.new),
      syncConfigRepositoryProvider.overrideWithValue(_DemoSyncConfigs()),
      organisationRepositoryProvider.overrideWith((ref) => _DemoOrganisations()),
      sportRepositoryProvider.overrideWith((ref) => _DemoSports(ref.read(apiClientProvider))),
      // The installed build may be older than the one in the store
      appUpdateAvailableProvider.overrideWith((ref) => false),
      onboardingSeenProvider.overrideWith(_IntroSeen.new),
    ],
  );
  await _walkThrough(container.read(routerProvider));
}

/// Opens each screen and prints `SHOT <name>`; `store_assets/capture.sh` takes the picture.
Future<void> _walkThrough(GoRouter router) async {
  Future<void> shot(String name, {Duration settle = const Duration(seconds: 6)}) async {
    await Future<void>.delayed(settle);
    debugPrint('SHOT $name');
    await Future<void>.delayed(const Duration(seconds: 3));
  }

  await shot('01_sportarten', settle: const Duration(seconds: 8));
  router.go('/sport/demo-org-root');
  await shot('05_verein');
  router.go('/sport/$_leagueId');
  await shot('02_liga');
  router.go('/abos');
  await shot('03_abos', settle: const Duration(seconds: 3));
  final context = router.routerDelegate.navigatorKey.currentContext!;
  final abo = (await _DemoSyncConfigs().getAll()).first;
  if (!context.mounted) return;
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => CalendarSheet(config: abo),
    ),
  );
  await shot('04_kalender', settle: const Duration(seconds: 2));
  debugPrint('SHOT done');
}

/// NLA Männer (Eishockey) on dev.synci.ch
const _leagueId = 'aabc54f9-2fc6-4f6d-ae84-cf1b2ab29720';

const _organisation = MyOrganisation(
  id: 'demo-org',
  name: 'FC Seeblick',
  description: 'Fussballclub mit Aktiven und Junioren',
  role: OrgRole.member,
  status: OrgMemberStatus.active,
  sport: Sport(
    id: 'demo-org-root',
    label: 'FC Seeblick',
    organisationId: 'demo-org',
    subSports: [
      Sport(id: 'demo-grp-1', label: '1. Mannschaft', organisationId: 'demo-org'),
      Sport(id: 'demo-grp-2', label: 'Junioren', organisationId: 'demo-org'),
    ],
  ),
);

class _IntroSeen extends OnboardingSeenController {
  @override
  bool build() => true;
}

class _DemoUser extends AuthController {
  @override
  Future<AppUser?> build() async => const AppUser(name: 'Andri', email: 'andri@example.com');
}

class _DemoOrganisations extends OrganisationRepository {
  _DemoOrganisations() : super(_unused);

  @override
  Future<List<MyOrganisation>> getMine() async => const [_organisation];
}

class _DemoSports extends SportRepository {
  const _DemoSports(super.api);

  @override
  Future<PagedResult<SportEvent>> getEvents(String sportId, {required int page, required int pageSize}) async {
    if (!sportId.startsWith('demo-')) return super.getEvents(sportId, page: page, pageSize: pageSize);
    final events = _organisationEvents().where((e) => sportId == 'demo-org-root' || e.sportId == sportId).toList();
    return PagedResult(amount: events.length, elements: events);
  }
}

List<SportEvent> _organisationEvents() {
  final today = DateTime.now();
  final monday = DateTime(today.year, today.month, today.day).add(Duration(days: 8 - today.weekday));
  DateTime at(int day, int hour, [int minute = 0]) => monday.add(Duration(days: day, hours: hour, minutes: minute));
  SportEvent event(
    String id,
    String name,
    DateTime start,
    String group, {
    int hours = 2,
    String? location,
    bool allDay = false,
  }) => SportEvent(
    id: id,
    sourceId: 99,
    name: name,
    startsOn: start,
    endsOn: allDay ? null : start.add(Duration(hours: hours)),
    sportId: group,
    location: location,
  );
  return [
    event('d1', 'Training', at(1, 19), 'demo-grp-1', location: 'Sportplatz Seeblick'),
    event('d2', 'Training', at(2, 18), 'demo-grp-2', hours: 1, location: 'Sportplatz Seeblick'),
    event('d3', 'Training', at(3, 19), 'demo-grp-1', location: 'Sportplatz Seeblick'),
    event('d4', 'FC Seeblick – FC Talwil', at(5, 16), 'demo-grp-1', location: 'Sportplatz Seeblick'),
    event('d5', 'Vereinsfest', at(6, 0), 'demo-org-root', location: 'Clubhaus', allDay: true),
  ];
}

class _DemoSyncConfigs extends SyncConfigRepository {
  _DemoSyncConfigs() : super(_unused);

  var _configs = [
    const SyncConfig(
      id: 'demo-abo',
      name: 'Mein Sport',
      sports: [
        Sport(id: '2811d68a-bb0d-4249-9080-29815c8c03c6', label: 'Super League', rootSport: 'Fussball'),
        Sport(id: 'b3276cfd-7707-4e45-a0a3-bff8e3d4077b', label: 'World Cup Männer', rootSport: 'Ski Alpin'),
        Sport(id: '93bc46c1-646a-4a34-8bd1-ac4e531cd33e', label: 'Formel 1', rootSport: 'Motorsport'),
        Sport(id: 'demo-grp-1', label: '1. Mannschaft', rootSport: 'FC Seeblick', organisationId: 'demo-org'),
      ],
      teams: [
        Team(id: '21', sourceId: 3, name: 'ZSC Lions', gender: 'MAN', rootSport: 'Eishockey'),
        Team(id: '7', sourceId: 3, name: 'HC Davos', gender: 'MAN', rootSport: 'Eishockey'),
      ],
    ),
  ];

  @override
  Future<List<SyncConfig>> getAll() async => _configs;

  @override
  Future<SyncConfig> update(SyncConfig config) async {
    _configs = [for (final c in _configs) c.id == config.id ? config : c];
    return config;
  }
}

// The demo repositories never reach the network
final _unused = ApiClient(baseUrl: Uri.parse('http://localhost/'), accessToken: () async => null);
