import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/calendar/calendar_sheet.dart';
import 'package:synci/features/calendar/open_in_browser.dart';
import 'package:synci/features/sync_config/sync_config.dart';

void main() {
  testWidgets('Google auf Android: erst die Schritte, dann Browser mit kopiertem Link', (tester) async {
    final opened = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(browserChannel, (call) async {
      opened.add(call.arguments);
      return true;
    });
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => showCalendarSheet(context, ref, const SyncConfig(id: 'abc', name: 'Test')),
                child: const Text('Sheet'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zu Google Kalender hinzufügen'));
    await tester.pumpAndSettle();
    expect(find.text('Google Kalender am Handy'), findsOneWidget);
    expect(opened, isEmpty, reason: 'der Browser öffnet erst nach den Schritten');

    await tester.tap(find.text('Google Kalender öffnen'));
    await tester.pumpAndSettle();

    expect(copied, endsWith('/api/calendars/abc/subscribe'));
    expect(copied, startsWith('https://'));
    expect(opened.single, startsWith('https://calendar.google.com/calendar/r?cid=webcal'));
    expect(find.text('Google Kalender am Handy'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
