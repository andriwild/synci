import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sport/sport.dart';
import 'sync_config.dart';
import 'sync_config_providers.dart';

Set<String> _subtree(Sport sport) => {sport.id, for (final sub in sport.subSports) ..._subtree(sub)};

/// Distinct entries of [configs] in [sport] or below it. Teams and Top Events carry no sport id,
/// so only a [root] counts them, by its name.
int aboEntriesIn(Sport sport, List<SyncConfig> configs, {bool root = false}) {
  final ids = _subtree(sport);
  return {
    for (final config in configs) ...[
      for (final s in config.sports)
        if (ids.contains(s.id)) 'sport:${s.id}',
      for (final e in config.events)
        if (ids.contains(e.sportId) || (root && e.rootSport == sport.label)) 'event:${e.id}',
      if (root)
        for (final t in config.teams)
          if (t.rootSport == sport.label) 'team:${t.id}',
      if (root && sport.isTopEvents)
        for (final m in config.matchups) 'matchup:${([m.teamA.id, m.teamB.id]..sort()).join('-')}',
    ],
  }.length;
}

/// A check with the number of entries in my Abos; takes no space while there are none.
class AboBadge extends ConsumerWidget {
  const AboBadge({super.key, required this.sport, this.root = false});

  final Sport sport;

  /// See [aboEntriesIn].
  final bool root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final configs = ref.watch(syncConfigsProvider).value ?? const <SyncConfig>[];
    final count = aboEntriesIn(sport, configs, root: root);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: child,
      ),
      child: count == 0
          ? const SizedBox.shrink(key: ValueKey(0))
          : Semantics(
              key: ValueKey(count),
              label: '$count im Abo',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
                decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Icon(Icons.check, size: 14, color: theme.colorScheme.onPrimary),
                    Text(
                      '$count',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
