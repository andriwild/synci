import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:synci/app.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/sport_repository.dart';
import 'package:synci/features/sync_config/sync_config_providers.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sportRepositoryProvider.overrideWithValue(_FakeSportRepository()),
          activeSyncConfigIdProvider.overrideWith(_NoSelection.new),
        ],
        child: const SynciApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Sportarten aufklappen und Details öffnen', (tester) async {
    await pumpApp(tester);

    expect(find.text('Basketball'), findsOneWidget);
    expect(find.text('NBA'), findsNothing);

    await tester.tap(find.text('Basketball'));
    await tester.pumpAndSettle();
    expect(find.text('NBA'), findsOneWidget);

    await tester.tap(find.byTooltip('NBA öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('Teams (1)'), findsOneWidget);
    expect(find.text('Atlanta Hawks'), findsOneWidget);
    expect(find.text('Lugano Tigers - Massagno'), findsOneWidget);
    expect(find.text('17.10.2026'), findsOneWidget);
    expect(find.text('Melde dich an, um Abos zu speichern'), findsOneWidget);
  });

  testWidgets('Hinzufügen ohne Login fragt nach Anmeldung', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Basketball öffnen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alle hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Melde dich an, um Sportarten'), findsOneWidget);
  });
}

class _NoSelection extends ActiveSyncConfigIdController {
  @override
  String? build() => null;
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
      PagedResult(
        amount: 1,
        elements: [
          SportEvent(id: '1', sourceId: 3, name: 'Lugano Tigers - Massagno', startsOn: DateTime(2026, 10, 17, 17)),
        ],
      );
}
