import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/app_update/app_store_lookup.dart';
import 'package:synci/features/app_update/app_store_update_repository.dart';
import 'package:synci/features/app_update/app_update_repository.dart';
import 'package:synci/features/app_update/version_order.dart';

import 'fakes/fake_http_adapter.dart';

void main() {
  final page = Uri.parse('https://apps.apple.com/ch/app/synci/id1234567890');

  Map<String, Object> listing(String version) => {
    'resultCount': 1,
    'results': [
      {'version': version, 'trackViewUrl': '$page', 'bundleId': 'ch.synci.app'},
    ],
  };

  group('isLaterVersion', () {
    test('vergleicht die Versionen Zahl für Zahl', () {
      expect(isLaterVersion('1.10.0', '1.9.2'), isTrue);
      expect(isLaterVersion('2.0', '1.9.9'), isTrue);
      expect(isLaterVersion('1.0.1', '1.0'), isTrue);
    });

    test('gleiche oder ältere Versionen sind nicht neuer', () {
      expect(isLaterVersion('1.0.0', '1.0.0'), isFalse);
      expect(isLaterVersion('1.0', '1.0.0'), isFalse);
      expect(isLaterVersion('0.9.9', '1.0.0'), isFalse);
    });
  });

  group('AppStoreLookup', () {
    late FakeHttpAdapter adapter;

    AppStoreLookup lookup() {
      adapter = FakeHttpAdapter();
      return AppStoreLookup(Dio()..httpClientAdapter = adapter, bundleId: 'ch.synci.app');
    }

    test('fragt den Schweizer Store nach der Bundle-ID und liest Version und Store-Seite', () async {
      final appStore = lookup();
      adapter.respond(200, listing('1.2.0'), contentType: 'text/javascript; charset=utf-8');

      expect(await appStore.fetch(), (version: '1.2.0', page: page));
      final url = adapter.lastRequest!.uri;
      expect(url.host, 'itunes.apple.com');
      expect(url.path, '/lookup');
      expect(url.queryParameters, {'bundleId': 'ch.synci.app', 'country': 'ch'});
    });

    test('ohne Treffer ist die App nicht im Verkauf', () async {
      final appStore = lookup();
      adapter.respond(200, {'resultCount': 0, 'results': <Object>[]});

      expect(await appStore.fetch(), isNull);
    });

    test('unbekannte Antworten und Fehlerstatus werfen', () async {
      final appStore = lookup();
      adapter.respond(200, {'errorMessage': 'Invalid value(s) for key(s): [bundleId]'});
      await expectLater(appStore.fetch(), throwsFormatException);

      adapter.respond(503, {'error': 'down'});
      await expectLater(appStore.fetch(), throwsA(isA<DioException>()));
    });
  });

  group('AppStoreUpdateRepository', () {
    late FakeHttpAdapter adapter;
    late List<Uri> opened;

    AppStoreUpdateRepository repository(Object body, {String installed = '1.0.0', bool opens = true}) {
      adapter = FakeHttpAdapter()..respond(200, body);
      opened = [];
      return AppStoreUpdateRepository(
        AppStoreLookup(Dio()..httpClientAdapter = adapter, bundleId: 'ch.synci.app'),
        installedVersion: () async => installed,
        open: (uri) async {
          opened.add(uri);
          return opens;
        },
      );
    }

    test('eine neuere Version im App Store öffnet deren Seite', () async {
      final updates = repository(listing('1.1.0'));

      expect(await updates.isUpdateAvailable(), isTrue);
      await updates.update();
      expect(opened, [page]);
    });

    test('die installierte Version oder keine im Store ist kein Update', () async {
      for (final body in [
        listing('1.0.0'),
        {'resultCount': 0, 'results': <Object>[]},
      ]) {
        final updates = repository(body);

        expect(await updates.isUpdateAvailable(), isFalse);
        await expectLater(updates.update(), throwsA(isA<AppUpdateException>()));
        expect(opened, isEmpty);
      }
    });

    test('lässt sich die Store-Seite nicht öffnen, wirft das Update', () async {
      final updates = repository(listing('1.1.0'), opens: false);

      expect(await updates.isUpdateAvailable(), isTrue);
      await expectLater(updates.update(), throwsA(isA<AppUpdateException>()));
    });
  });
}
