import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../sport/sport.dart';
import '../sport/sport_providers.dart';
import '../sync_config/sync_config_providers.dart';
import 'organisation.dart';
import 'organisation_repository.dart';

/// My organisations, active and pending; empty when logged out.
final myOrganisationsProvider = FutureProvider<List<MyOrganisation>>((ref) async {
  final user = await ref.watch(authControllerProvider.future);
  if (user == null) return const [];
  return ref.read(organisationRepositoryProvider).getMine();
});

/// The sport tree: my active organisations first, then the public sports.
final sportTreeProvider = FutureProvider<List<Sport>>((ref) async {
  final sports = await ref.watch(sportsProvider.future);
  // A failing organisation request must not hide the public tree
  final organisations = ref.watch(myOrganisationsProvider).value ?? const <MyOrganisation>[];
  return [
    for (final organisation in organisations)
      if (!organisation.isPending) organisation.sport,
    ...sports,
  ];
});

/// The active organisation a root or group node belongs to.
final organisationOfSportProvider = Provider.family<MyOrganisation?, String>((ref, sportId) {
  final organisations = ref.watch(myOrganisationsProvider).value ?? const <MyOrganisation>[];
  for (final organisation in organisations) {
    if (organisation.isPending) continue;
    if (organisation.sport.id == sportId || organisation.groups.any((g) => g.id == sportId)) return organisation;
  }
  return null;
});

final organisationDetailProvider = FutureProvider.autoDispose.family<MyOrganisation, String>(
  (ref, id) => ref.read(organisationRepositoryProvider).getById(id),
);

final organisationMembersProvider = FutureProvider.autoDispose.family<List<OrganisationMember>, String>(
  (ref, id) => ref.read(organisationRepositoryProvider).getMembers(id),
);

/// Answers to the organisation's events that ask for them, by event id.
final eventResponsesProvider = FutureProvider.autoDispose.family<Map<String, EventResponseSummary>, String>((
  ref,
  organisationId,
) async {
  final summaries = await ref.read(organisationRepositoryProvider).getResponses(organisationId);
  return {for (final summary in summaries) summary.eventId: summary};
});

final discoverProvider = AsyncNotifierProvider.autoDispose
    .family<DiscoverController, PagedItems<OrganisationSummary>, String>(DiscoverController.new);

class DiscoverController extends PagedController<OrganisationSummary> {
  DiscoverController(this.search);

  final String search;

  @override
  int get pageSize => 20;

  @override
  Future<PagedResult<OrganisationSummary>> fetchPage(int page) =>
      ref.read(organisationRepositoryProvider).discover(search: search, page: page, pageSize: pageSize);

  @override
  String idOf(OrganisationSummary item) => item.id;
}

/// Reloads what a mutation changed, like the cache tags on the website.
void refreshOrganisations(
  WidgetRef ref, {
  bool mine = true,
  bool discover = false,
  String? members,
  bool events = false,
  bool syncConfigs = false,
}) {
  if (mine) ref.invalidate(myOrganisationsProvider);
  if (discover) ref.invalidate(discoverProvider);
  if (members != null) {
    ref.invalidate(organisationMembersProvider(members));
    ref.invalidate(organisationDetailProvider(members));
  }
  if (events) {
    ref.invalidate(eventsProvider);
    ref.invalidate(eventResponsesProvider);
  }
  if (syncConfigs) ref.invalidate(syncConfigsProvider);
}
