import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/analytics/analytics.dart';
import '../sport/team_logo.dart';
import 'abo_actions.dart';
import 'sync_config.dart';

final _dateFormat = DateFormat('d.M.yyyy', 'de_CH');

class AboItemsList extends ConsumerWidget {
  const AboItemsList({super.key, required this.config});

  final SyncConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (config.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('Noch keine Sportarten, Teams oder Events im Abo.'),
      );
    }

    void track(String type, String name, String? sport) =>
        ref.read(analyticsProvider).event('subscription-remove', {'type': type, 'name': name, 'sport': sport});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (config.sports.isNotEmpty) const _SectionTitle('Sportarten'),
        for (final sport in config.sports)
          _AboItemTile(
            icon: sport.isOrganisation ? Icons.apartment : Icons.emoji_events_outlined,
            title: sport.label,
            subtitle: sport.rootSport != sport.label ? sport.rootSport : null,
            onRemove: () => removeFromAbo(
              context,
              ref,
              config,
              change: (c) => c.copyWith(
                sports: [
                  for (final s in c.sports)
                    if (s.id != sport.id) s,
                ],
              ),
              message: '${sport.label} entfernt',
              onRemoved: () => track('sport', sport.label, sport.rootSport),
            ),
          ),
        if (config.teams.isNotEmpty) const _SectionTitle('Teams'),
        for (final team in config.teams)
          _AboItemTile(
            icon: Icons.groups_outlined,
            leading: TeamLogo(team: team, size: 32),
            title: team.displayName,
            subtitle: team.rootSport,
            onRemove: () => removeFromAbo(
              context,
              ref,
              config,
              change: (c) => c.copyWith(
                teams: [
                  for (final t in c.teams)
                    if (t.id != team.id) t,
                ],
              ),
              message: '${team.name} entfernt',
              onRemoved: () => track('team', team.name, team.rootSport),
            ),
          ),
        if (config.matchups.isNotEmpty) const _SectionTitle('Top Events'),
        for (final matchup in config.matchups)
          _AboItemTile(
            icon: Icons.emoji_events_outlined,
            title: matchup.name,
            titleWidget: GameTitle(teams: [matchup.teamA, matchup.teamB], name: matchup.name, logoSize: 32),
            subtitle: matchup.rootSport,
            centered: true,
            onRemove: () => removeFromAbo(
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
              onRemoved: () => track('matchup', matchup.name, matchup.rootSport),
            ),
          ),
        if (config.events.isNotEmpty) const _SectionTitle('Events'),
        for (final event in config.events)
          _AboItemTile(
            icon: Icons.event_outlined,
            title: event.name,
            titleWidget: GameTitle(teams: event.teams, name: event.name, logoSize: 32),
            subtitle: [if (event.startsOn != null) _dateFormat.format(event.startsOn!), ?event.rootSport].join(' · '),
            centered: event.teams.length >= 2,
            onRemove: () => removeFromAbo(
              context,
              ref,
              config,
              change: (c) => c.copyWith(
                events: [
                  for (final e in c.events)
                    if (e.id != event.id) e,
                ],
              ),
              message: '${event.name} entfernt',
              onRemoved: () => track('event', event.name, event.rootSport),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 4),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge),
  );
}

class _AboItemTile extends StatelessWidget {
  const _AboItemTile({
    required this.icon,
    this.leading,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.centered = false,
    required this.onRemove,
  });

  final IconData icon;

  /// replaces [icon], e.g. with a team logo
  final Widget? leading;
  final String title;

  /// replaces the plain [title], e.g. with the teams of a game
  final Widget? titleWidget;
  final String? subtitle;

  /// Centers the subtitle below a game, whose teams sit around the middle.
  final bool centered;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = this.subtitle;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: leading ?? Icon(icon),
      title: titleWidget ?? Text(title),
      subtitle: subtitle == null || subtitle.isEmpty
          ? null
          : Text(
              subtitle,
              textAlign: centered ? TextAlign.center : null,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
      trailing: IconButton(tooltip: 'Entfernen', icon: const Icon(Icons.delete_outline), onPressed: onRemove),
    );
  }
}
