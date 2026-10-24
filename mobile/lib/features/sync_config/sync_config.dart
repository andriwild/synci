import '../sport/sport.dart';

/// Fallback for responses without `matchupLimit`.
const defaultMatchupLimit = 20;

/// A Top Event: every game between the two teams.
class Matchup {
  const Matchup({required this.sourceId, required this.teamA, required this.teamB, this.rootSport});

  factory Matchup.fromJson(Map<String, dynamic> json) => Matchup(
    sourceId: (json['sourceId'] as num).toInt(),
    teamA: Team.fromJson(json['teamA'] as Map<String, dynamic>),
    teamB: Team.fromJson(json['teamB'] as Map<String, dynamic>),
    rootSport: json['rootSport'] as String?,
  );

  final int sourceId;
  final Team teamA;
  final Team teamB;
  final String? rootSport;

  String get name => '${teamA.name} – ${teamB.name}';

  /// A – B and B – A are the same Top Event.
  bool isBetween(Team a, Team b) =>
      sourceId == a.sourceId && ((teamA.id == a.id && teamB.id == b.id) || (teamA.id == b.id && teamB.id == a.id));
}

class SyncConfig {
  const SyncConfig({
    required this.id,
    required this.name,
    this.sports = const [],
    this.teams = const [],
    this.events = const [],
    this.matchups = const [],
    this.matchupLimit = defaultMatchupLimit,
  });

  factory SyncConfig.fromJson(Map<String, dynamic> json) => SyncConfig(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    sports: [for (final s in json['sports'] as List<dynamic>? ?? const []) Sport.fromJson(s as Map<String, dynamic>)],
    teams: [for (final t in json['teams'] as List<dynamic>? ?? const []) Team.fromJson(t as Map<String, dynamic>)],
    events: [
      for (final e in json['events'] as List<dynamic>? ?? const []) SportEvent.fromJson(e as Map<String, dynamic>),
    ],
    matchups: [
      for (final m in json['matchups'] as List<dynamic>? ?? const []) Matchup.fromJson(m as Map<String, dynamic>),
    ],
    matchupLimit: (json['matchupLimit'] as num?)?.toInt() ?? defaultMatchupLimit,
  );

  final String id;
  final String name;
  final List<Sport> sports;
  final List<Team> teams;
  final List<SportEvent> events;
  final List<Matchup> matchups;

  /// How many Top Events the Abo may hold.
  final int matchupLimit;

  int get itemCount => sports.length + teams.length + events.length + matchups.length;

  bool get isEmpty => itemCount == 0;

  bool get matchupsFull => matchups.length >= matchupLimit;

  bool containsSport(String sportId) => sports.any((s) => s.id == sportId);

  bool containsTeam(String teamId) => teams.any((t) => t.id == teamId);

  bool containsMatchup(Team a, Team b) => matchups.any((m) => m.isBetween(a, b));

  /// Also true if the whole sport of the event is in the config.
  bool coversEvent(SportEvent event, {String? viaSportId}) =>
      events.any((e) => e.id == event.id) ||
      (event.sportId != null && containsSport(event.sportId!)) ||
      (viaSportId != null && containsSport(viaSportId));

  SyncConfig copyWith({
    String? name,
    List<Sport>? sports,
    List<Team>? teams,
    List<SportEvent>? events,
    List<Matchup>? matchups,
  }) => SyncConfig(
    id: id,
    name: name ?? this.name,
    sports: sports ?? this.sports,
    teams: teams ?? this.teams,
    events: events ?? this.events,
    matchups: matchups ?? this.matchups,
    matchupLimit: matchupLimit,
  );

  Map<String, dynamic> toRequestJson() => {
    'id': id,
    'name': name,
    'sports': [for (final s in sports) s.id],
    'teams': [
      for (final t in teams) {'id': t.id, 'sourceId': t.sourceId},
    ],
    'events': [
      for (final e in events) {'id': e.id, 'sourceId': e.sourceId},
    ],
    'matchups': [
      for (final m in matchups) {'sourceId': m.sourceId, 'teamAId': m.teamA.id, 'teamBId': m.teamB.id},
    ],
  };
}
