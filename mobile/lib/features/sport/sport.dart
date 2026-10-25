/// Name of the root that shows the Top Events of my Abos.
const topEventsName = 'TOP_EVENTS';

class Sport {
  const Sport({
    required this.id,
    required this.label,
    this.name = '',
    this.subSports = const [],
    this.rootSport,
    this.organisationId,
    this.hasTeams = false,
  });

  factory Sport.fromJson(Map<String, dynamic> json) => Sport(
    id: json['id'] as String,
    label: (json['label'] ?? json['name'] ?? '') as String,
    name: json['name'] as String? ?? '',
    subSports: [
      for (final sub in (json['subSports'] as List<dynamic>? ?? const [])) Sport.fromJson(sub as Map<String, dynamic>),
    ],
    rootSport: json['rootSport'] as String?,
    organisationId: json['organisationId'] as String?,
    hasTeams: json['hasTeams'] as bool? ?? false,
  );

  final String id;
  final String label;

  /// Technical key, e.g. `SOCCER` or [topEventsName].
  final String name;
  final List<Sport> subSports;

  /// Only set in sync config responses.
  final String? rootSport;

  /// Set on organisation roots and their groups.
  final String? organisationId;

  /// Teams play in this node or below it.
  final bool hasTeams;

  bool get isOrganisation => organisationId != null;

  bool get isTopEvents => name == topEventsName && !isOrganisation;

  bool get hasSubSports => subSports.isNotEmpty;
}

typedef SportNode = ({Sport sport, int level});

SportNode? findSport(List<Sport> sports, String id, [int level = 0]) {
  for (final sport in sports) {
    if (sport.id == id) return (sport: sport, level: level);
    final found = findSport(sport.subSports, id, level + 1);
    if (found != null) return found;
  }
  return null;
}

class Team {
  const Team({
    required this.id,
    required this.sourceId,
    required this.name,
    this.gender,
    this.rootSport,
    this.logoUrl,
    this.logoSrcSet,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'].toString(),
    sourceId: (json['sourceId'] as num).toInt(),
    name: json['name'] as String? ?? '',
    gender: json['gender'] as String?,
    rootSport: json['rootSport'] as String?,
    logoUrl: json['logoUrl'] as String?,
    logoSrcSet: json['logoSrcSet'] as String?,
  );

  final String id;
  final int sourceId;
  final String name;

  /// `WOMAN`, `MAN`, `BOTH` or `UNKNOWN`.
  final String? gender;
  final String? rootSport;
  final String? logoUrl;

  /// Sharper logo variants as HTML srcset (`url 1x, url 2x, …`), if the source has several sizes.
  final String? logoSrcSet;

  /// The logo for [density], picked from [logoSrcSet] like a browser does.
  String? logoFor(double density) {
    final candidates = [
      for (final candidate in (logoSrcSet ?? '').split(','))
        if (candidate.trim().split(RegExp(r'\s+')) case [final url, final descriptor] when descriptor.endsWith('x'))
          if (double.tryParse(descriptor.substring(0, descriptor.length - 1)) case final value?)
            (url: url, density: value),
    ]..sort((a, b) => a.density.compareTo(b.density));
    if (candidates.isEmpty) return logoUrl;
    return (candidates.where((c) => c.density >= density).firstOrNull ?? candidates.last).url;
  }

  String get displayName => switch (gender) {
    'WOMAN' => '$name (W)',
    'BOTH' => '$name (W/M)',
    _ => name,
  };
}

class SportEvent {
  const SportEvent({
    required this.id,
    required this.sourceId,
    required this.name,
    this.startsOn,
    this.endsOn,
    this.sportId,
    this.rootSport,
    this.location,
    this.description,
    this.responseRequested = false,
    this.teams = const [],
  });

  factory SportEvent.fromJson(Map<String, dynamic> json) => SportEvent(
    id: json['id'].toString(),
    sourceId: (json['sourceId'] as num).toInt(),
    name: json['name'] as String? ?? '',
    // No time zone: local time, as on the website
    startsOn: DateTime.tryParse(json['startsOn'] as String? ?? ''),
    endsOn: DateTime.tryParse(json['endsOn'] as String? ?? ''),
    sportId: json['sportId'] as String?,
    rootSport: json['rootSport'] as String?,
    location: json['location'] as String?,
    description: json['description'] as String?,
    responseRequested: json['responseRequested'] as bool? ?? false,
    teams: [for (final t in json['teams'] as List<dynamic>? ?? const []) Team.fromJson(t as Map<String, dynamic>)],
  );

  final String id;
  final int sourceId;
  final String name;
  final DateTime? startsOn;

  /// `null` for all-day organisation events.
  final DateTime? endsOn;
  final String? sportId;
  final String? rootSport;
  final String? location;
  final String? description;

  /// Organisation events can ask their members to answer yes or no.
  final bool responseRequested;

  /// Both teams of a game in the order of its name; empty for events without teams.
  final List<Team> teams;
}

class PagedResult<T> {
  const PagedResult({required this.amount, required this.elements});

  factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) => PagedResult(
    amount: (json['amount'] as num).toInt(),
    elements: [for (final e in json['elements'] as List<dynamic>) fromJson(e as Map<String, dynamic>)],
  );

  /// Total across all pages.
  final int amount;
  final List<T> elements;
}
