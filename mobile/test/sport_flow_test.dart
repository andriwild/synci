import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:synci/app.dart';
import 'package:synci/features/app_update/app_update_providers.dart';
import 'package:synci/features/onboarding/onboarding_providers.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/sport_repository.dart';

import 'helpers/phone_screen.dart';

void main() {
  setUpAll(() => initializeDateFormatting('de_CH'));

  Future<void> pumpApp(WidgetTester tester, {bool updateAvailable = false, int extraSports = 0}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sportRepositoryProvider.overrideWithValue(_FakeSportRepository(extraSports)),
          appUpdateAvailableProvider.overrideWithValue(AsyncData(updateAvailable)),
          onboardingSeenProvider.overrideWith(_OnboardingSeen.new),
        ],
        child: const SynciApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('die Startseite zeigt die Organisationen gleich über den Sportarten', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Hallo'), findsNothing, reason: 'keine Begrüssung, der Platz gehört dem Inhalt');
    expect(anywhere('Sportarten'), findsOneWidget);
    expect(anywhere('Basketball'), findsOneWidget);
    expect(anywhere('Organisationen'), findsWidgets);
    expect(
      tester.getTopLeft(anywhere('Entdecken')).dy,
      lessThan(tester.getTopLeft(anywhere('Basketball')).dy),
      reason: 'die Organisationen sind nicht unter allen Sportarten versteckt',
    );

    await scrollToAndTap(tester, 'Entdecken');
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Melde dich an, um einer Organisation beizutreten'), findsOneWidget);
  });

  testWidgets('Sportart öffnen, Liga wählen und Details sehen', (tester) async {
    await pumpApp(tester);

    await scrollToAndTap(tester, 'Basketball');
    expect(find.text('Ganze Sportart'), findsOneWidget);
    expect(find.text('Ligen und Wettbewerbe'), findsOneWidget);

    await tester.tap(find.byTooltip('NBA öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('Teams (1)'), findsOneWidget);
    expect(find.text('Atlanta Hawks'), findsOneWidget);
    expect(find.text('AH'), findsOneWidget, reason: 'Teams ohne Logo zeigen ihre Initialen');
    expect(find.text('Lugano Tigers - Massagno'), findsOneWidget);
    expect(find.text('17.10.2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Ganze Sportart'), findsOneWidget, reason: 'zurück geht es zu den Ligen');
  });

  testWidgets('das Sportart-Icon fliegt von der Kachel in den Titel der Ligen', (tester) async {
    await pumpApp(tester);
    await tester.ensureVisible(anywhere('Basketball'));
    await tester.pumpAndSettle();
    final icon = find.byIcon(Icons.sports_basketball);
    final start = tester.getCenter(icon);

    await tester.tap(find.text('Basketball'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final middle = tester.getCenter(icon.last);
    await tester.pumpAndSettle();
    final end = tester.getCenter(find.descendant(of: find.byType(AppBar), matching: icon));

    expect(middle.dy, lessThan(start.dy), reason: 'unterwegs nach oben');
    expect(middle.dy, greaterThan(end.dy), reason: 'noch nicht im Titel');
  });

  testWidgets('die Suche findet Ligen im ganzen Baum', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField), 'nb');
    await tester.pumpAndSettle();
    expect(find.text('NBA'), findsOneWidget);
    expect(find.text('Sportarten'), findsNothing);

    await tester.tap(find.text('NBA'));
    await tester.pumpAndSettle();
    expect(find.text('Teams (1)'), findsOneWidget);

    await tester.tap(find.byTooltip('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Ganze Sportart'), findsOneWidget);
  });

  testWidgets('beim Scrollen wird das Suchfeld zur Lupe in der Kopfzeile', (tester) async {
    await pumpApp(tester, extraSports: 12);
    final search = find.byTooltip('Suchen');
    expect(
      tester.widget<IgnorePointer>(find.ancestor(of: search, matching: find.byType(IgnorePointer)).first).ignoring,
      isTrue,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(
      tester.widget<IgnorePointer>(find.ancestor(of: search, matching: find.byType(IgnorePointer)).first).ignoring,
      isFalse,
    );

    await tester.tap(search);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue);
    final logo = find.byWidgetPredicate((w) => w is Image && w.semanticLabel == 'Synci');
    expect(tester.getSize(logo).height, greaterThan(40), reason: 'das Logo ist wieder gross');
    expect(
      tester.getTopLeft(find.byType(TextField)).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(logo).dy),
      reason: 'das Suchfeld steht wieder unter dem Logo',
    );
  });

  testWidgets('die Startseite zeigt eine neuere Version über den Sportarten', (tester) async {
    await pumpApp(tester, updateAvailable: true);

    expect(find.text('Update verfügbar'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Update verfügbar')).dy, lessThan(tester.getTopLeft(anywhere('Basketball')).dy));
  });

  testWidgets('Hinzufügen ohne Login fragt nach Anmeldung', (tester) async {
    await pumpApp(tester);

    await scrollToAndTap(tester, 'Basketball');
    await tester.tap(find.text('Ganze Sportart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alle hinzufügen'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('Melde dich an, um Sportarten'), findsOneWidget);
  });
}

class _OnboardingSeen extends OnboardingSeenController {
  @override
  bool build() => true;
}

class _FakeSportRepository implements SportRepository {
  _FakeSportRepository([this.extraSports = 0]);

  /// More root sports, to make the start screen scroll.
  final int extraSports;

  @override
  Future<List<Sport>> getSports() async => [
    const Sport(
      id: 'basketball',
      label: 'Basketball',
      subSports: [Sport(id: 'nba', label: 'NBA')],
    ),
    for (var i = 0; i < extraSports; i++) Sport(id: 'sport-$i', label: 'Sport $i'),
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
