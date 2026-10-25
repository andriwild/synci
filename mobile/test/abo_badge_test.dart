import 'package:flutter_test/flutter_test.dart';
import 'package:synci/features/sport/sport.dart';
import 'package:synci/features/sync_config/abo_badge.dart';
import 'package:synci/features/sync_config/sync_config.dart';

const _nba = Sport(id: 'nba', label: 'NBA');
const _basketball = Sport(id: 'basketball', label: 'Basketball', subSports: [_nba]);
const _top = Sport(id: 'top', name: topEventsName, label: 'Top Events');
const _hawks = Team(id: '1', sourceId: 3, name: 'Atlanta Hawks', gender: 'MAN', rootSport: 'Basketball');
const _celtics = Team(id: '2', sourceId: 3, name: 'Boston Celtics', gender: 'MAN', rootSport: 'Basketball');

void main() {
  test('a sport counts what is in it or below it, each entry once across all Abos', () {
    final configs = [
      SyncConfig(
        id: 'a',
        name: 'A',
        sports: const [_nba],
        teams: const [_hawks],
        events: [const SportEvent(id: 'e1', sourceId: 3, name: 'Hawks - Celtics', sportId: 'nba')],
      ),
      const SyncConfig(id: 'b', name: 'B', sports: [_nba], teams: [_hawks, _celtics]),
    ];

    expect(aboEntriesIn(_basketball, configs, root: true), 4, reason: 'NBA, das Spiel und zwei Teams');
    expect(aboEntriesIn(_nba, configs), 2, reason: 'Teams haben keine Liga, nur die Sportart zählt sie');
    expect(aboEntriesIn(const Sport(id: 'ski', label: 'Ski Alpin'), configs, root: true), 0);
  });

  test('Top Events count the matchups, whichever team comes first', () {
    const configs = [
      SyncConfig(
        id: 'a',
        name: 'A',
        matchups: [Matchup(sourceId: 3, teamA: _hawks, teamB: _celtics)],
      ),
      SyncConfig(
        id: 'b',
        name: 'B',
        matchups: [Matchup(sourceId: 3, teamA: _celtics, teamB: _hawks)],
      ),
    ];

    expect(aboEntriesIn(_top, configs, root: true), 1);
    expect(aboEntriesIn(_basketball, configs, root: true), 0);
  });
}
