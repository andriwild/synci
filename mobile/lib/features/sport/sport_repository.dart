import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_controller.dart';
import 'sport.dart';

final sportRepositoryProvider = Provider((ref) => SportRepository(ref.read(apiClientProvider)));

class SportRepository {
  const SportRepository(this._api);

  final ApiClient _api;

  Future<List<Sport>> getSports() async {
    final body = await _api.get('sports') as List<dynamic>;
    return [for (final json in body) Sport.fromJson(json as Map<String, dynamic>)];
  }

  Future<PagedResult<Team>> getTeams(
    String sportId, {
    required int page,
    required int pageSize,
    String search = '',
  }) async {
    final body = await _api.get(
      'sports/$sportId/teams',
      query: {'page': page, 'pageSize': pageSize, if (search.isNotEmpty) 'searchTerm': search},
    );
    return PagedResult.fromJson(body as Map<String, dynamic>, Team.fromJson);
  }

  Future<PagedResult<SportEvent>> getEvents(String sportId, {required int page, required int pageSize}) async {
    final body = await _api.get('sports/$sportId/events', query: {'page': page, 'pageSize': pageSize});
    return PagedResult.fromJson(body as Map<String, dynamic>, SportEvent.fromJson);
  }
}
