import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_controller.dart';
import '../sport/sport.dart';
import 'organisation.dart';

final organisationRepositoryProvider = Provider((ref) => OrganisationRepository(ref.read(apiClientProvider)));

class OrganisationRepository {
  const OrganisationRepository(this._api);

  final ApiClient _api;

  Future<List<MyOrganisation>> getMine() async {
    final body = await _api.get('organisations') as List<dynamic>;
    return [for (final json in body) MyOrganisation.fromJson(json as Map<String, dynamic>)];
  }

  Future<PagedResult<OrganisationSummary>> discover({
    required String search,
    required int page,
    required int pageSize,
  }) async {
    final body = await _api.get(
      'organisations/discover',
      query: {'page': page, 'pageSize': pageSize, if (search.isNotEmpty) 'searchTerm': search},
    );
    return PagedResult.fromJson(body as Map<String, dynamic>, OrganisationSummary.fromJson);
  }

  Future<MyOrganisation> getById(String id) async {
    final json = await _api.get('organisations/$id') as Map<String, dynamic>;
    return MyOrganisation.fromJson({...json, 'status': 'ACTIVE'});
  }

  Future<void> create({required String name, String? description}) =>
      _api.post('organisations', {'name': name, 'description': ?description});

  Future<void> delete(String id) => _api.delete('organisations/$id');

  Future<void> requestJoin(String id) => _api.post('organisations/$id/join-requests', null);

  Future<void> leave(String id) => _api.delete('organisations/$id/members/me');

  Future<List<OrganisationMember>> getMembers(String id) async {
    final body = await _api.get('organisations/$id/members') as List<dynamic>;
    return [for (final json in body) OrganisationMember.fromJson(json as Map<String, dynamic>)];
  }

  Future<void> approveMember(String id, String memberId) =>
      _api.put('organisations/$id/members/$memberId/approve', null);

  Future<void> updateMemberRole(String id, String memberId, OrgRole role) =>
      _api.put('organisations/$id/members/$memberId/role', {'role': role.json});

  Future<void> removeMember(String id, String memberId) => _api.delete('organisations/$id/members/$memberId');

  Future<void> createGroup(String id, String name) => _api.post('organisations/$id/groups', {'name': name});

  Future<void> renameGroup(String id, String groupId, String name) =>
      _api.put('organisations/$id/groups/$groupId', {'name': name});

  Future<void> deleteGroup(String id, String groupId) => _api.delete('organisations/$id/groups/$groupId');

  Future<void> createEvent(String id, OrganisationEventRequest event) =>
      _api.post('organisations/$id/events', event.toJson());

  Future<void> updateEvent(String id, String eventId, OrganisationEventRequest event) =>
      _api.put('organisations/$id/events/$eventId', event.toJson());

  Future<void> deleteEvent(String id, String eventId) => _api.delete('organisations/$id/events/$eventId');

  /// Answers to the organisation's events from today on that ask for them.
  Future<List<EventResponseSummary>> getResponses(String id) async {
    final body = await _api.get('organisations/$id/responses') as List<dynamic>;
    return [for (final e in body) EventResponseSummary.fromJson(e as Map<String, dynamic>)];
  }

  Future<EventResponseSummary> answer(String id, String eventId, EventAnswer answer) async {
    final json = await _api.put('organisations/$id/events/$eventId/response', {'answer': answer.json});
    return EventResponseSummary.fromJson(json as Map<String, dynamic>);
  }
}
