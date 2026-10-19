import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synci/core/api/api_client.dart';

import 'fakes/fake_http_adapter.dart';

void main() {
  group('unwrapEnvelope', () {
    test('gibt body bei statusCode OK zurück', () {
      final body = unwrapEnvelope({
        'headers': {},
        'body': [1, 2],
        'statusCode': 'OK',
        'statusCodeValue': 200,
      });
      expect(body, [1, 2]);
    });

    test('wirft bei Fehler-Status mit der Meldung aus body', () {
      expect(
        () => unwrapEnvelope({
          'headers': {},
          'body': 'The requested element was not found',
          'statusCode': 'NOT_FOUND',
          'statusCodeValue': 404,
        }),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 'NOT_FOUND')
              .having((e) => e.message, 'message', 'Ein Fehler ist aufgetreten: The requested element was not found'),
        ),
      );
    });

    test('wirft bei Antworten ohne Envelope', () {
      expect(() => unwrapEnvelope('<html>'), throwsA(isA<ApiException>()));
    });
  });

  group('ApiClient', () {
    late FakeHttpAdapter adapter;

    ApiClient client({String? token}) {
      adapter = FakeHttpAdapter();
      return ApiClient(
        baseUrl: Uri.parse('https://synci.ch/api/'),
        accessToken: () async => token,
        dio: Dio()..httpClientAdapter = adapter,
      );
    }

    test('hängt das Access Token an und baut die URL relativ zu /api/', () async {
      final api = client(token: 'abc');
      adapter.respond(200, {'body': 'ok', 'statusCode': 'OK'});

      expect(await api.get('sports/1/teams', query: {'page': 0}), 'ok');
      expect(adapter.lastRequest!.uri.toString(), 'https://synci.ch/api/sports/1/teams?page=0');
      expect(adapter.lastRequest!.headers['Authorization'], 'Bearer abc');
    });

    test('ohne Anmeldung kein Authorization-Header', () async {
      final api = client();
      adapter.respond(200, {'body': [], 'statusCode': 'OK'});

      await api.get('sports');
      expect(adapter.lastRequest!.headers.containsKey('Authorization'), isFalse);
    });

    test('HTTP 401 wird zu SessionExpiredException', () async {
      final api = client(token: 'abgelaufen');
      adapter.respond(401, {'error': 'unauthorized'});

      expect(api.get('syncconfigs'), throwsA(isA<SessionExpiredException>()));
    });

    test('Fehlerstatus liefert die Meldung des Backends', () async {
      final api = client(token: 'abc');
      adapter.respond(400, {
        'headers': {},
        'body': 'Der letzte Admin kann den Verein nicht verlassen oder herabgestuft werden',
        'statusCode': 'BAD_REQUEST',
        'statusCodeValue': 400,
      });

      expect(
        api.delete('organisations/1/members/me'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 'BAD_REQUEST')
              .having((e) => e.message, 'message', startsWith('Der letzte Admin')),
        ),
      );
    });
  });
}
