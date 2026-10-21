import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sport/team_logo.dart';
import 'package:synci/features/sync_config/sync_config.dart';

void main() {
  group('Sport', () {
    final tree = [
      for (final json in [
        {
          'id': 'basketball',
          'name': 'BASKETBALL',
          'label': 'Basketball',
          'subSports': [
            {
              'id': 'nba',
              'name': 'NBA',
              'label': 'NBA',
              'subSports': [
                {'id': 'nba-east', 'name': 'EAST', 'label': null, 'subSports': []},
              ],
            },
          ],
        },
      ])
        Sport.fromJson(json),
    ];

    test('liest den Baum und fällt ohne label auf name zurück', () {
      expect(tree.single.label, 'Basketball');
      expect(tree.single.subSports.single.subSports.single.label, 'EAST');
      expect(tree.single.hasSubSports, isTrue);
    });

    test('findSport liefert Sportart und Ebene', () {
      final node = findSport(tree, 'nba-east');
      expect(node?.sport.label, 'EAST');
      expect(node?.level, 2);
      expect(findSport(tree, 'unbekannt'), isNull);
    });
  });

  test('Team zeigt das Geschlecht wie die Website an', () {
    Team team(String gender) => Team.fromJson({'id': '1', 'sourceId': 3, 'name': 'Zug', 'gender': gender});
    expect(team('WOMAN').displayName, 'Zug (W)');
    expect(team('BOTH').displayName, 'Zug (W/M)');
    expect(team('MAN').displayName, 'Zug');
  });

  group('Teamlogo', () {
    const cdn = 'https://cdn-csd.swisstxt.ch/images/sport/club/logo';
    final team = Team.fromJson({
      'id': '21',
      'sourceId': 3,
      'name': 'ZSC Lions',
      'logoUrl': '$cdn/medium/21.png',
      'logoSrcSet': '$cdn/medium/21.png 1x, $cdn/large/21.png 2x, $cdn/300/21.png 3x',
    });

    test('wählt wie ein Browser die kleinste Variante, die scharf genug ist', () {
      expect(team.logoFor(1), '$cdn/medium/21.png');
      expect(team.logoFor(1.5), '$cdn/large/21.png');
      expect(team.logoFor(2), '$cdn/large/21.png');
      expect(team.logoFor(2.625), '$cdn/300/21.png');
      expect(team.logoFor(4), '$cdn/300/21.png');
    });

    test('ohne srcset bleibt es beim einen Logo', () {
      const single = Team(id: '1', sourceId: 7, name: 'Chicago Bears', logoUrl: 'https://nfl/chi.png');
      expect(single.logoFor(3), 'https://nfl/chi.png');
      expect(const Team(id: '2', sourceId: 3, name: 'Zug').logoFor(3), isNull);
    });

    test('Initialen wie auf der Website', () {
      expect(teamInitials('Chicago Bears'), 'CB');
      expect(teamInitials('Zug'), 'ZU');
      expect(teamInitials('HC Fribourg-Gottéron'), 'HF');
      expect(teamInitials('1. FC Köln'), 'FK');
      expect(teamInitials('76ers'), '76');
    });
  });

  group('SyncConfig', () {
    final config = SyncConfig.fromJson({
      'id': 'abo-1',
      'name': 'Standard-Abo',
      'sports': [
        {'id': 'nba', 'name': 'NBA', 'label': 'NBA', 'parentId': 'basketball', 'rootSport': 'Basketball'},
      ],
      'teams': [
        {'id': '8678', 'sourceId': 3, 'name': 'Atlanta Hawks', 'gender': 'MAN', 'rootSport': 'Basketball'},
      ],
      'events': [
        {
          'id': '1854818',
          'sourceId': 3,
          'name': 'Lugano Tigers - Massagno',
          'startsOn': '2026-10-17T17:00:00',
          'endsOn': '2026-10-17T19:00:00',
          'sportId': 'sbl',
          'locationId': null,
          'rootSport': 'Basketball',
        },
      ],
    });

    test('liest die Abo-Antwort inkl. rootSport', () {
      expect(config.itemCount, 3);
      expect(config.sports.single.rootSport, 'Basketball');
      expect(config.events.single.startsOn, DateTime(2026, 10, 17, 17));
    });

    test('baut den PUT-Body wie syncConfigDtoMapper im Web', () {
      expect(config.toRequestJson(), {
        'id': 'abo-1',
        'name': 'Standard-Abo',
        'sports': ['nba'],
        'teams': [
          {'id': '8678', 'sourceId': 3},
        ],
        'events': [
          {'id': '1854818', 'sourceId': 3},
        ],
      });
    });

    test('ein Event ist auch über seine Sportart abgedeckt', () {
      const other = SportEvent(id: 'x', sourceId: 3, name: 'Spiel', sportId: 'nba');
      const unrelated = SportEvent(id: 'y', sourceId: 3, name: 'Spiel', sportId: 'nfl');
      expect(config.coversEvent(other), isTrue);
      expect(config.coversEvent(unrelated), isFalse);
      expect(config.coversEvent(unrelated, viaSportId: 'nba'), isTrue);
    });
  });
}
