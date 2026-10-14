import '../sport/sport.dart';

class SyncConfig {
  const SyncConfig({
    required this.id,
    required this.name,
    this.sports = const [],
    this.teams = const [],
    this.events = const [],
  });

  factory SyncConfig.fromJson(Map<String, dynamic> json) => SyncConfig(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    sports: [for (final s in json['sports'] as List<dynamic>? ?? const []) Sport.fromJson(s as Map<String, dynamic>)],
    teams: [for (final t in json['teams'] as List<dynamic>? ?? const []) Team.fromJson(t as Map<String, dynamic>)],
    events: [
      for (final e in json['events'] as List<dynamic>? ?? const []) SportEvent.fromJson(e as Map<String, dynamic>),
    ],
  );

  final String id;
  final String name;
  final List<Sport> sports;
  final List<Team> teams;
  final List<SportEvent> events;

  int get itemCount => sports.length + teams.length + events.length;

  bool get isEmpty => itemCount == 0;

  bool containsSport(String sportId) => sports.any((s) => s.id == sportId);

  bool containsTeam(String teamId) => teams.any((t) => t.id == teamId);

  /// Also true if the whole sport of the event is in the config.
  bool coversEvent(SportEvent event, {String? viaSportId}) =>
      events.any((e) => e.id == event.id) ||
      (event.sportId != null && containsSport(event.sportId!)) ||
      (viaSportId != null && containsSport(viaSportId));

  SyncConfig copyWith({String? name, List<Sport>? sports, List<Team>? teams, List<SportEvent>? events}) => SyncConfig(
    id: id,
    name: name ?? this.name,
    sports: sports ?? this.sports,
    teams: teams ?? this.teams,
    events: events ?? this.events,
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
  };
}
