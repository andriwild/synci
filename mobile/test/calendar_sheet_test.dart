import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/calendar/calendar_sheet.dart';
import 'package:synci/features/calendar/open_in_browser.dart';
import 'package:synci/features/sync_config/sync_config.dart';

void main() {
  testWidgets('Google auf Android öffnet direkt den Browser, ohne Anleitung', (tester) async {
    final opened = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(browserChannel, (call) async {
      opened.add(call.arguments);
      return true;
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

    expect(opened.single, startsWith('https://calendar.google.com/calendar/r?cid=webcal'));
    expect(opened.single, endsWith(Uri.encodeQueryComponent('/api/calendars/abc/subscribe')));
    expect(find.byType(AlertDialog), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
