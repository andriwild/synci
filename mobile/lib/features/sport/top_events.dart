import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/analytics/analytics.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
import '../account/login_prompt.dart';
import '../sync_config/abo_actions.dart';
import '../sync_config/sync_config.dart';
import '../sync_config/sync_config_providers.dart';
import 'sport.dart';
import 'sport_providers.dart';
import 'team_logo.dart';
import 'top_event_repository.dart';

final _gameFormat = DateFormat('E d.M.yyyy, HH:mm', 'de_CH');

/// Top Events page: the matchups of each Abo with their next game, to add and remove.
class TopEventsView extends ConsumerWidget {
  const TopEventsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final configs = ref.watch(syncConfigsProvider).value ?? const <SyncConfig>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Wähle zwei Teams, und alle Spiele zwischen ihnen kommen in dein Abo, egal in welchem Wettbewerb.',
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _openCreateSheet(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Hinzufügen'),
                ),
              ],
            ),
          ),
        ),
        for (final config in configs) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(config.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Text(
                  '${config.matchups.length} von ${config.matchupLimit} genutzt',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
          ),
          if (config.matchups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Noch keine Top Events in diesem Abo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            )
          else
            for (final matchup in config.matchups) _TopEventTile(config: config, matchup: matchup),
        ],
      ],
    );
  }

  Future<void> _openCreateSheet(BuildContext context, WidgetRef ref) async {
    if (ref.read(authControllerProvider).value == null) {
      await showLoginPrompt(context, ref, message: 'Melde dich an, um Top Events in deinem Abo zu speichern.');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const CreateTopEventSheet(),
    );
  }
}

class _TopEventTile extends ConsumerWidget {
  const _TopEventTile({required this.config, required this.matchup});

  final SyncConfig config;
  final Matchup matchup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(
      matchupPreviewProvider((sourceId: matchup.sourceId, teamA: matchup.teamA.id, teamB: matchup.teamB.id)),
    );
    final next = games.value?.elements.firstOrNull;
    return Card(
      child: ListTile(
        title: GameTitle(teams: [matchup.teamA, matchup.teamB], name: matchup.name),
        subtitle: Text(
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
          switch (games) {
            AsyncData() when next?.startsOn != null => 'Nächstes Spiel: ${_gameFormat.format(next!.startsOn!)}',
            AsyncData() => 'Zurzeit kein Spiel angesetzt',
            AsyncError() => 'Nächstes Spiel nicht verfügbar',
            _ => '…',
          },
        ),
        trailing: IconButton(
          tooltip: '${matchup.name} entfernen',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => removeFromAbo(
            context,
            ref,
            config,
            change: (c) => c.copyWith(
              matchups: [
                for (final m in c.matchups)
                  if (!m.isBetween(matchup.teamA, matchup.teamB)) m,
              ],
            ),
            message: '${matchup.name} entfernt',
            onRemoved: () => ref.read(analyticsProvider).event('subscription-remove', {
              'type': 'matchup',
              'name': matchup.name,
              'sport': matchup.rootSport,
            }),
          ),
        ),
      ),
    );
  }
}

/// Picks a sport and two of its teams and adds every game between them to one or more Abos.
class CreateTopEventSheet extends ConsumerStatefulWidget {
  const CreateTopEventSheet({super.key});

  @override
  ConsumerState<CreateTopEventSheet> createState() => _CreateTopEventSheetState();
}

class _CreateTopEventSheetState extends ConsumerState<CreateTopEventSheet> {
  Sport? _sport;
  Team? _teamA;
  Team? _teamB;
  var _saving = false;

  Future<void> _pickTeam({required bool first}) async {
    final sport = _sport;
    if (sport == null) return;
    final team = await showModalBottomSheet<Team>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _TeamPickerSheet(sport: sport, other: first ? _teamB : _teamA),
    );
    if (team == null || !mounted) return;
    setState(() {
      if (first) {
        _teamA = team;
      } else {
        _teamB = team;
      }
    });
  }

  AboItem _item(Sport sport, Team teamA, Team teamB) {
    final name = '${teamA.name} – ${teamB.name}';
    return AboItem(
      label: name,
      contains: (c) => c.containsMatchup(teamA, teamB),
      blockedReason: (c) => c.matchupsFull ? 'Alle ${c.matchupLimit} Top Events genutzt' : null,
      add: (c) => c.copyWith(
        matchups: [
          ...c.matchups,
          Matchup(sourceId: teamA.sourceId, teamA: teamA, teamB: teamB, rootSport: sport.label),
        ],
      ),
      remove: (c) => c.copyWith(
        matchups: [
          for (final m in c.matchups)
            if (!m.isBetween(teamA, teamB)) m,
        ],
      ),
      analytics: {'type': 'matchup', 'name': name, 'sport': sport.label},
    );
  }

  Future<void> _add() async {
    final item = _item(_sport!, _teamA!, _teamB!);
    // With several Abos the picker opens on top, so there is nothing to wait for here
    final direct = (ref.read(syncConfigsProvider).value ?? const <SyncConfig>[]).length <= 1;
    if (direct) setState(() => _saving = true);
    await chooseAbos(context, ref, item);
    if (!mounted) return;
    if ((ref.read(syncConfigsProvider).value ?? const <SyncConfig>[]).any(item.contains)) {
      Navigator.of(context).pop();
    } else if (direct) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sports = [
      for (final sport in ref.watch(sportsProvider).value ?? const <Sport>[])
        if (sport.hasTeams && !sport.isTopEvents && !sport.isOrganisation) sport,
    ];
    final configs = ref.watch(syncConfigsProvider).value ?? const <SyncConfig>[];
    // With several Abos the picker shows where the Top Event already is and which Abos are full
    final single = configs.length == 1 ? configs.single : null;
    final (teamA, teamB) = (_teamA, _teamB);
    final included = teamA != null && teamB != null && (single?.containsMatchup(teamA, teamB) ?? false);
    final full = single?.matchupsFull ?? false;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Top Event hinzufügen', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _sport?.id,
              decoration: const InputDecoration(labelText: 'Sportart'),
              items: [for (final sport in sports) DropdownMenuItem(value: sport.id, child: Text(sport.label))],
              onChanged: (id) => setState(() {
                _sport = sports.where((s) => s.id == id).firstOrNull;
                _teamA = null;
                _teamB = null;
              }),
            ),
            const SizedBox(height: 12),
            _TeamField(label: 'Team 1', team: teamA, enabled: _sport != null, onTap: () => _pickTeam(first: true)),
            const SizedBox(height: 8),
            _TeamField(label: 'Team 2', team: teamB, enabled: _sport != null, onTap: () => _pickTeam(first: false)),
            const SizedBox(height: 12),
            if (included)
              const _Hint(icon: Icons.info_outline, text: 'Dieses Top Event ist schon in deinem Abo.')
            else if (teamA != null && teamB != null)
              _Preview(query: (sourceId: teamA.sourceId, teamA: teamA.id, teamB: teamB.id)),
            if (single != null) ...[
              const SizedBox(height: 8),
              Text(
                '${single.matchups.length} von ${single.matchupLimit} Top Events genutzt',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: teamA == null || teamB == null || included || full || _saving ? null : _add,
              child: _saving
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(configs.length > 1 ? 'Abos wählen' : 'Zum Abo hinzufügen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamField extends StatelessWidget {
  const _TeamField({required this.label, required this.team, required this.enabled, required this.onTap});

  final String label;
  final Team? team;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final team = this.team;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: enabled ? 'Team wählen' : 'Zuerst Sportart wählen',
          // Keeps the label above the hint instead of on top of it
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabled: enabled,
          suffixIcon: const Icon(Icons.search),
        ),
        isEmpty: team == null,
        child: team == null
            ? null
            : Row(
                children: [
                  TeamLogo(team: team, size: 24),
                  const SizedBox(width: 8),
                  Expanded(child: Text(team.displayName, overflow: TextOverflow.ellipsis)),
                ],
              ),
      ),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({required this.query});

  final MatchupQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(matchupPreviewProvider(query))
      .when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => _Hint(icon: Icons.error_outline, text: errorText(error)),
        data: (games) => games.amount == 0
            ? const _Hint(
                icon: Icons.info_outline,
                text: 'Zurzeit ist kein Spiel zwischen diesen Teams angesetzt. Neue Spiele kommen automatisch in dein Abo.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    games.amount == 1 ? '1 Spiel geplant' : '${games.amount} Spiele geplant',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  for (final game in games.elements)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        spacing: 2,
                        children: [
                          if (game.startsOn != null)
                            Text(
                              _gameFormat.format(game.startsOn!),
                              style: TextStyle(color: Theme.of(context).colorScheme.outline),
                            ),
                          GameTitle(teams: game.teams, name: game.name, logoSize: 32),
                        ],
                      ),
                    ),
                ],
              ),
      );
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Expanded(child: Text(text)),
    ],
  );
}

/// Searchable list of the teams of [sport]; [other] and teams of another source are left out.
class _TeamPickerSheet extends ConsumerStatefulWidget {
  const _TeamPickerSheet({required this.sport, this.other});

  final Sport sport;
  final Team? other;

  @override
  ConsumerState<_TeamPickerSheet> createState() => _TeamPickerSheetState();
}

class _TeamPickerSheetState extends ConsumerState<_TeamPickerSheet> {
  Timer? _debounce;
  String _search = '';

  @override
  void dispose() {
    _debounce?.cancel();
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
    final other = widget.other;

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Team in ${widget.sport.label} suchen',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            Expanded(
              child: teams.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(teamsProvider(query))),
                data: (paged) {
                  final candidates = [
                    for (final team in paged.items)
                      if (team.id != other?.id && (other == null || team.sourceId == other.sourceId)) team,
                  ];
                  if (candidates.isEmpty) return const Center(child: Text('Kein Team gefunden'));
                  return ListView(
                    children: [
                      for (final team in candidates)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: TeamLogo(team: team),
                          title: Text(team.displayName),
                          onTap: () => Navigator.of(context).pop(team),
                        ),
                      if (paged.hasMore)
                        Center(
                          child: TextButton(
                            onPressed: paged.isLoadingMore
                                ? null
                                : () => ref.read(teamsProvider(query).notifier).loadMore().catchError((Object e) {
                                    if (context.mounted) showMessage(context, errorText(e));
                                  }),
                            child: const Text('Mehr anzeigen'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
