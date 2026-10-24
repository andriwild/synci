import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_controller.dart';
import 'sport.dart';

final topEventRepositoryProvider = Provider((ref) => TopEventRepository(ref.read(apiClientProvider)));

typedef MatchupQuery = ({int sourceId, String teamA, String teamB});

/// The next games between two teams, to preview a Top Event before it is added.
final matchupPreviewProvider = FutureProvider.autoDispose.family<PagedResult<SportEvent>, MatchupQuery>(
  (ref, query) => ref.read(topEventRepositoryProvider).getUpcomingGames(query, pageSize: 3),
);

class TopEventRepository {
  const TopEventRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<SportEvent>> getUpcomingGames(MatchupQuery query, {required int pageSize}) async {
    final body = await _api.get(
      'matchups/events',
      query: {'sourceId': query.sourceId, 'teamA': query.teamA, 'teamB': query.teamB, 'page': 0, 'pageSize': pageSize},
    );
    return PagedResult.fromJson(body as Map<String, dynamic>, SportEvent.fromJson);
  }
}
