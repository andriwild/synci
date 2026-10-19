import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/app_update/app_update_providers.dart';
import 'package:synci/features/app_update/app_update_repository.dart';
import 'package:synci/features/app_update/update_banner.dart';

import 'fakes/fake_app_update_repository.dart';

void main() {
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer containerWith(AppUpdateRepository updates) => ProviderContainer.test(
    retry: (_, _) => null,
    overrides: [appUpdateRepositoryProvider.overrideWithValue(updates)],
  );

  testWidgets('eine neuere Version zeigt den Hinweis und startet das Update', (tester) async {
    final updates = FakeAppUpdateRepository(available: true);
    container = containerWith(updates);
    await pump(tester, const UpdateBanner());

    expect(find.text('Update verfügbar'), findsOneWidget);
    expect(find.text('Eine neue Version von Synci ist bereit.'), findsOneWidget);
    await tester.tap(find.text('Aktualisieren'));
    await tester.pumpAndSettle();

    expect(updates.updates, 1);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('klappt das Update nicht, verweist eine Meldung auf den Store', (tester) async {
    container = containerWith(FakeAppUpdateRepository(available: true, updateFails: true));
    await pump(tester, const UpdateBanner());

    await tester.tap(find.text('Aktualisieren'));
    await tester.pumpAndSettle();

    expect(find.text('Das Update hat nicht geklappt. Versuch es im Store.'), findsOneWidget);
  });

  testWidgets('ohne Update oder wenn der Store nicht antwortet, kein Hinweis', (tester) async {
    for (final updates in [FakeAppUpdateRepository(), _FailingCheck()]) {
      container = containerWith(updates);
      await pump(tester, const UpdateBanner());

      expect(find.text('Update verfügbar'), findsNothing);
    }
  });

  testWidgets('der Store wird nur einmal pro App-Start gefragt', (tester) async {
    final updates = FakeAppUpdateRepository(available: true);
    container = containerWith(updates);

    await pump(tester, const UpdateBanner());
    await pump(tester, const SizedBox());
    await pump(tester, const UpdateBanner());

    expect(find.text('Update verfügbar'), findsOneWidget);
    expect(updates.checks, 1);
  });
}

class _FailingCheck extends FakeAppUpdateRepository {
  @override
  Future<bool> isUpdateAvailable() async => throw const AppUpdateException('not installed from a store');
}
