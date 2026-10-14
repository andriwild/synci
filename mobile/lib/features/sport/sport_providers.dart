import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sport.dart';
import 'sport_repository.dart';

final sportsProvider = FutureProvider<List<Sport>>((ref) => ref.read(sportRepositoryProvider).getSports());

class PagedItems<T> {
  const PagedItems({required this.items, required this.total, this.isLoadingMore = false});

  final List<T> items;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => items.length < total;
}

abstract class PagedController<T> extends AsyncNotifier<PagedItems<T>> {
  int _page = 0;

  int get pageSize;

  Future<PagedResult<T>> fetchPage(int page);

  String idOf(T item);

  @override
  Future<PagedItems<T>> build() async {
    _page = 0;
    final result = await fetchPage(0);
    return PagedItems(items: result.elements, total: result.amount);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(PagedItems(items: current.items, total: current.total, isLoadingMore: true));
    try {
      final result = await fetchPage(_page + 1);
      if (!ref.mounted) return;
      _page++;
      final known = {for (final item in current.items) idOf(item)};
      state = AsyncData(
        PagedItems(
          items: [...current.items, ...result.elements.where((item) => !known.contains(idOf(item)))],
          total: result.amount,
        ),
      );
    } on Exception {
      if (ref.mounted) state = AsyncData(current);
      rethrow;
    }
  }
}

typedef TeamsQuery = ({String sportId, String search});

final teamsProvider = AsyncNotifierProvider.autoDispose.family<TeamsController, PagedItems<Team>, TeamsQuery>(
  TeamsController.new,
);

class TeamsController extends PagedController<Team> {
  TeamsController(this.query);

  final TeamsQuery query;

  @override
  int get pageSize => 8;

  @override
  Future<PagedResult<Team>> fetchPage(int page) =>
      ref.read(sportRepositoryProvider).getTeams(query.sportId, page: page, pageSize: pageSize, search: query.search);

  @override
  String idOf(Team item) => item.id;
}

final eventsProvider = AsyncNotifierProvider.autoDispose.family<EventsController, PagedItems<SportEvent>, String>(
  EventsController.new,
);

class EventsController extends PagedController<SportEvent> {
  EventsController(this.sportId);

  final String sportId;

  @override
  int get pageSize => 5;

  @override
  Future<PagedResult<SportEvent>> fetchPage(int page) =>
      ref.read(sportRepositoryProvider).getEvents(sportId, page: page, pageSize: pageSize);

  @override
  String idOf(SportEvent item) => item.id;
}
