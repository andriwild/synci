import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lays the app out on an iPhone-sized screen (390 × 844) instead of the default 800 × 600 test surface.
void usePhoneScreen(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1170, 2532)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Finds [text] also below the fold; the test font is much wider than Montserrat.
Finder anywhere(String text) => find.text(text, skipOffstage: false);

/// Scrolls [text] into view and taps it.
Future<void> scrollToAndTap(WidgetTester tester, String text) async {
  await tester.ensureVisible(anywhere(text));
  await tester.pumpAndSettle();
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
