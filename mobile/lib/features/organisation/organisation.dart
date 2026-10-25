import '../sport/sport.dart';

enum OrgRole {
  admin('ADMIN', 'Admin'),
  member('MEMBER', 'Mitglied');

  const OrgRole(this.json, this.label);

  final String json;
  final String label;

  static OrgRole fromJson(Object? value) => value == 'ADMIN' ? admin : member;
}

enum OrgMemberStatus {
  pending,
  active;

  static OrgMemberStatus? fromJson(Object? value) => switch (value) {
    'ACTIVE' => active,
    'PENDING' => pending,
    _ => null,
  };
}

/// An organisation I belong to, with its sport tree: the root and its groups.
class MyOrganisation {
  const MyOrganisation({
    required this.id,
    required this.name,
    this.description,
    required this.role,
    required this.status,
    required this.sport,
  });

  factory MyOrganisation.fromJson(Map<String, dynamic> json) => MyOrganisation(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    role: OrgRole.fromJson(json['role']),
    status: OrgMemberStatus.fromJson(json['status']) ?? OrgMemberStatus.pending,
    sport: Sport.fromJson(json['sport'] as Map<String, dynamic>),
  );

  final String id;
  final String name;
  final String? description;
  final OrgRole role;
  final OrgMemberStatus status;
  final Sport sport;

  bool get isAdmin => role == OrgRole.admin && status == OrgMemberStatus.active;
  bool get isPending => status == OrgMemberStatus.pending;
  List<Sport> get groups => sport.subSports;
}

class OrganisationSummary {
  const OrganisationSummary({
    required this.id,
    required this.name,
    this.description,
    required this.memberCount,
    this.membershipStatus,
  });

  factory OrganisationSummary.fromJson(Map<String, dynamic> json) => OrganisationSummary(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
    membershipStatus: OrgMemberStatus.fromJson(json['membershipStatus']),
  );

  final String id;
  final String name;
  final String? description;

  /// Active members only.
  final int memberCount;

  /// `null` when I am neither a member nor have asked to join.
  final OrgMemberStatus? membershipStatus;
}

class OrganisationMember {
  const OrganisationMember({
    required this.id,
    this.name,
    this.email,
    required this.role,
    required this.status,
    required this.isMe,
  });

  factory OrganisationMember.fromJson(Map<String, dynamic> json) => OrganisationMember(
    id: json['id'] as String,
    name: json['name'] as String?,
    email: json['email'] as String?,
    role: OrgRole.fromJson(json['role']),
    status: OrgMemberStatus.fromJson(json['status']) ?? OrgMemberStatus.pending,
    isMe: json['isMe'] as bool? ?? false,
  );

  /// Membership id, used in the member endpoints.
  final String id;
  final String? name;
  final String? email;
  final OrgRole role;
  final OrgMemberStatus status;
  final bool isMe;

  String get displayName =>
      [name, email].firstWhere((s) => s != null && s.isNotEmpty, orElse: () => null) ?? 'Unbekannt';
}

class OrganisationEventRequest {
  const OrganisationEventRequest({
    required this.name,
    required this.sportId,
    required this.startsOn,
    this.endsOn,
    this.location,
    this.description,
    this.responseRequested = false,
  });

  final String name;
  final String sportId;
  final DateTime startsOn;

  /// `null` for all-day events.
  final DateTime? endsOn;
  final String? location;
  final String? description;
  final bool responseRequested;

  Map<String, dynamic> toJson() => {
    'name': name,
    'sportId': sportId,
    'startsOn': formatLocalDateTime(startsOn),
    if (endsOn case final end?) 'endsOn': formatLocalDateTime(end),
    'location': ?_nullIfBlank(location),
    'description': ?_nullIfBlank(description),
    if (responseRequested) 'responseRequested': true,
  };
}

enum EventAnswer {
  yes('YES', 'Ja'),
  no('NO', 'Nein');

  const EventAnswer(this.json, this.label);

  final String json;
  final String label;

  static EventAnswer? fromJson(Object? value) => switch (value) {
    'YES' => yes,
    'NO' => no,
    _ => null,
  };
}

/// Answers of the active members to an event that asks for them.
class EventResponseSummary {
  const EventResponseSummary({
    required this.eventId,
    required this.yes,
    required this.no,
    required this.open,
    this.myAnswer,
    this.members,
  });

  factory EventResponseSummary.fromJson(Map<String, dynamic> json) => EventResponseSummary(
    eventId: json['eventId'] as String,
    yes: (json['yes'] as num?)?.toInt() ?? 0,
    no: (json['no'] as num?)?.toInt() ?? 0,
    open: (json['open'] as num?)?.toInt() ?? 0,
    myAnswer: EventAnswer.fromJson(json['myAnswer']),
    members: switch (json['members']) {
      final List<dynamic> members => [
        for (final m in members.cast<Map<String, dynamic>>())
          (name: m['name'] as String? ?? 'Unbekannt', answer: EventAnswer.fromJson(m['answer'])),
      ],
      _ => null,
    },
  );

  final String eventId;
  final int yes;
  final int no;

  /// Active members without an answer.
  final int open;
  final EventAnswer? myAnswer;

  /// Every active member with their answer; only admins get it.
  final List<({String name, EventAnswer? answer})>? members;
}

String? _nullIfBlank(String? value) => (value == null || value.trim().isEmpty) ? null : value.trim();

/// Local wall-clock time without zone, as the backend expects: `2026-11-20T19:00:00`.
String formatLocalDateTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-${two(value.month)}-${two(value.day)}'
      'T${two(value.hour)}:${two(value.minute)}:00';
}
