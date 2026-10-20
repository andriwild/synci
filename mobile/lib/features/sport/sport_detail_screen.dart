import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/analytics/analytics.dart';
import '../../core/widgets/feedback.dart';
import '../organisation/organisation.dart';
import '../organisation/organisation_detail.dart';
import '../organisation/organisation_providers.dart';
import '../sync_config/abo_actions.dart';
import '../sync_config/active_abo_bar.dart';
import '../sync_config/sync_config_providers.dart';
import 'sport.dart';
import 'sport_providers.dart';
import 'team_logo.dart';

final _dateFormat = DateFormat('d.M.yyyy', 'de_CH');

class SportDetailScreen extends ConsumerWidget {
  const SportDetailScreen({super.key, required this.sportId});

  final String sportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sports = ref.watch(sportTreeProvider);
    final node = sports.value == null ? null : findSport(sports.value!, sportId);

    return Scaffold(
      appBar: AppBar(title: Text(node?.sport.label ?? '')),
      bottomNavigationBar: const ActiveAboBar(),
      body: switch (node) {
        _ when sports.isLoading => const Center(child: CircularProgressIndicator()),
        _ when sports.hasError => ErrorView(error: sports.error!, onRetry: () => ref.invalidate(sportsProvider)),
        final node? when node.sport.isOrganisation => switch (ref.watch(organisationOfSportProvider(sportId))) {
          null => const EmptyView(icon: Icons.lock_outline, message: 'Diese Organisation ist nicht mehr verfügbar.'),
          final organisation => _SportDetail(sport: node.sport, organisation: organisation),
        },
        null => const EmptyView(icon: Icons.search_off, message: 'Diese Sportart gibt es nicht mehr.'),
        final node => _SportDetail(sport: node.sport),
      },
    );
  }
}

class _SportDetail extends ConsumerWidget {
  const _SportDetail({required this.sport, this.organisation});

  final Sport sport;
  final MyOrganisation? organisation;

  Widget _eventTrailing(BuildContext context, WidgetRef ref, SportEvent event) {
    final active = ref.watch(activeSyncConfigProvider);
    if (active?.coversEvent(event, viaSportId: sport.id) ?? false) {
      return const Icon(Icons.check_circle, semanticLabel: 'Im Abo');
    }
    return IconButton(
      tooltip: 'Event hinzufügen',
      icon: const Icon(Icons.add_circle_outline),
      onPressed: () => editActiveAbo(
        context,
        ref,
        change: (c) => c.copyWith(events: [...c.events, event]),
        message: '${event.name} hinzugefügt',
        onSaved: () => ref.read(analyticsProvider).event('subscription-add', {
          'type': 'event',
          'name': event.name,
          if (organisation == null) 'sport': sport.label,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSyncConfigProvider);
    final events = ref.watch(eventsProvider(sport.id));
    final sportAdded = active?.containsSport(sport.id) ?? false;
    final organisation = this.organisation;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        events.value?.total.toString() ?? '–',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                      ),
                      const Text('Anzahl der Events'),
                    ],
                  ),
                ),
                sportAdded
                    ? const OutlinedButton(onPressed: null, child: Text('Im Abo'))
                    : FilledButton.icon(
                        onPressed: () => editActiveAbo(
                          context,
                          ref,
                          change: (c) => c.copyWith(sports: [...c.sports, sport]),
                          message: '${sport.label} hinzugefügt',
                          onSaved: () => ref.read(analyticsProvider).event('subscription-add', {
                            'type': 'sport',
                            'name': sport.label,
                          }),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Alle hinzufügen'),
                      ),
              ],
            ),
          ),
        ),
        if (organisation != null)
          OrganisationToolbar(organisation: organisation, sport: sport)
        else
          _TeamsSection(sport: sport),
        _SectionHeader(organisation == null ? 'Events' : 'Kommende Events'),
        ...events.when(
          loading: () => const [
            Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            ),
          ],
          error: (error, _) => [ErrorView(error: error, onRetry: () => ref.invalidate(eventsProvider(sport.id)))],
          data: (paged) => [
            if (organisation != null)
              OrganisationEventList(
                organisation: organisation,
                sport: sport,
                events: paged,
                trailing: (event) => _eventTrailing(context, ref, event),
              )
            else ...[
              if (paged.items.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Keine Events vorhanden')),
              for (final event in paged.items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(event.name),
                  subtitle: event.startsOn == null ? null : Text(_dateFormat.format(event.startsOn!)),
                  trailing: _eventTrailing(context, ref, event),
                ),
            ],
            if (paged.hasMore)
              _LoadMoreButton(
                loading: paged.isLoadingMore,
                onPressed: () => ref.read(eventsProvider(sport.id).notifier).loadMore(),
              ),
          ],
        ),
      ],
    );
  }
}

class _TeamsSection extends ConsumerStatefulWidget {
  const _TeamsSection({required this.sport});

  final Sport sport;

  @override
  ConsumerState<_TeamsSection> createState() => _TeamsSectionState();
}

class _TeamsSectionState extends ConsumerState<_TeamsSection> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _search = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => setState(() => _search = value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final query = (sportId: widget.sport.id, search: _search);
    final teams = ref.watch(teamsProvider(query));
    final active = ref.watch(activeSyncConfigProvider);

    if (_search.isEmpty && teams.value?.total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader('Teams${teams.value == null ? '' : ' (${teams.value!.total})'}'),
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Team suchen',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Suche löschen',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  ),
          ),
        ),
        ...teams.when(
          loading: () => const [
            Center(
              child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
            ),
          ],
          error: (error, _) => [ErrorView(error: error, onRetry: () => ref.invalidate(teamsProvider(query)))],
          data: (paged) => [
            if (paged.items.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Keine Teams vorhanden')),
            for (final team in paged.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: TeamLogo(team: team),
                title: Text(team.displayName),
                trailing: (active?.containsTeam(team.id) ?? false)
                    ? const Icon(Icons.check_circle, semanticLabel: 'Im Abo')
                    : IconButton(
                        tooltip: 'Team hinzufügen',
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => editActiveAbo(
                          context,
                          ref,
                          change: (c) => c.copyWith(teams: [...c.teams, team]),
                          message: '${team.name} hinzugefügt',
                          onSaved: () => ref.read(analyticsProvider).event('subscription-add', {
                            'type': 'team',
                            'name': team.name,
                            'sport': team.rootSport ?? widget.sport.label,
                          }),
                        ),
                      ),
              ),
            if (paged.hasMore)
              _LoadMoreButton(
                loading: paged.isLoadingMore,
                onPressed: () => ref.read(teamsProvider(query).notifier).loadMore(),
              ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
  );
}

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.loading, required this.onPressed});

  final bool loading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: loading
          ? null
          : () => onPressed().catchError((Object e) {
              if (context.mounted) showMessage(context, errorText(e));
            }),
      child: loading
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Mehr anzeigen'),
    ),
  );
}
