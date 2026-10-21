import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/team_logo.dart';

import 'helpers/phone_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester, Team team, {double size = 36}) async {
    usePhoneScreen(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TeamLogo(team: team, size: size),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ohne Logo zeigt das Team seine Initialen', (tester) async {
    await pump(tester, const Team(id: '1', sourceId: 7, name: 'Chicago Bears'));

    expect(find.text('CB'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('lädt das Logo nicht, erscheinen die Initialen', (tester) async {
    // Every request in widget tests fails with HTTP 400
    await pump(tester, const Team(id: '1', sourceId: 3, name: 'EV Zug', logoUrl: 'https://cdn/medium/1.png'));

    expect(find.text('EZ'), findsOneWidget);
  });

  testWidgets('lädt die Logo-Variante passend zur Pixeldichte', (tester) async {
    await pump(
      tester,
      const Team(
        id: '1',
        sourceId: 3,
        name: 'EV Zug',
        logoUrl: 'https://cdn/medium/1.png',
        logoSrcSet: 'https://cdn/medium/1.png 1x, https://cdn/large/1.png 2x, https://cdn/300/1.png 3x',
      ),
      size: 24,
    );

    // 24 px at 3x need the 2x variant of the website's 36 px logo
    final image = tester.widget<Image>(find.byType(Image, skipOffstage: false)).image as NetworkImage;
    expect(image.url, 'https://cdn/large/1.png');
  });
}
