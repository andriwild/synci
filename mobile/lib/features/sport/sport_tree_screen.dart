import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/widgets/feedback.dart';
import '../organisation/organisation_providers.dart';
import '../sync_config/abo_badge.dart';
import 'sport.dart';
import 'sport_icons.dart';
import 'sport_providers.dart';

const levelColors = [Color(0xFFB2BDCF), Color(0xFFC5CDD9), Color(0xFFD8DEE6), Color(0xFFE9EDF0), Color(0xFFF2F4F6)];

/// The leagues of a sport or the groups of an organisation, as an expandable tree.
class SportTreeScreen extends ConsumerStatefulWidget {
  const SportTreeScreen({super.key, required this.rootId});

  final String rootId;

  @override
  ConsumerState<SportTreeScreen> createState() => _SportTreeScreenState();
}

class _SportTreeScreenState extends ConsumerState<SportTreeScreen> {
  final _expanded = <String>{};

  void _openDetail(SportNode node) {
    // The root was tracked when it was opened on the start screen
    if (!node.sport.isOrganisation && node.level > 0) {
      ref.read(analyticsProvider).event('sport-select', {'sport': node.sport.label, 'level': node.level});
    }
    context.go('/sport/sportart/${widget.rootId}/${node.sport.id}');
  }

  List<SportNode> _visibleNodes(List<Sport> sports, int level) => [
    for (final sport in sports) ...[
      (sport: sport, level: level),
      if (_expanded.contains(sport.id)) ..._visibleNodes(sport.subSports, level + 1),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final tree = ref.watch(sportTreeProvider);
    final root = tree.value == null ? null : findSport(tree.value!, widget.rootId)?.sport;

    return Scaffold(
      appBar: AppBar(title: root == null ? null : SportTitle(sport: root)),
      body: tree.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(sportsProvider)),
        data: (_) {
          if (root == null) {
            return const EmptyView(icon: Icons.search_off, message: 'Diese Sportart gibt es nicht mehr.');
          }
          final nodes = _visibleNodes(root.subSports, 1);
          return RefreshIndicator(
            onRefresh: () =>
                Future.wait([ref.refresh(sportsProvider.future), ref.refresh(myOrganisationsProvider.future)]),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              children: [
                _WholeSportCard(sport: root, onTap: () => _openDetail((sport: root, level: 0))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                  child: Text(
                    root.isOrganisation ? 'Gruppen' : 'Ligen und Wettbewerbe',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                for (final node in nodes)
                  _SportRow(
                    node: node,
                    expanded: _expanded.contains(node.sport.id),
                    onTap: node.sport.hasSubSports
                        ? () => setState(() {
                            if (!_expanded.remove(node.sport.id)) _expanded.add(node.sport.id);
                          })
                        : () => _openDetail(node),
                    onOpen: () => _openDetail(node),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WholeSportCard extends StatelessWidget {
  const _WholeSportCard({required this.sport, required this.onTap});

  final Sport sport;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: levelColors.first,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(sportIcon(sport), color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(
        sport.isOrganisation ? 'Ganze Organisation' : 'Ganze Sportart',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text('Alle Events von ${sport.label}'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    ),
  );
}

class _SportRow extends StatelessWidget {
  const _SportRow({required this.node, required this.expanded, required this.onTap, required this.onOpen});

  /// Level 1 are the leagues or groups right below the root.
  final SportNode node;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final sport = node.sport;
    return Padding(
      padding: EdgeInsets.only(left: 16.0 * (node.level - 1), bottom: 6),
      child: Material(
        color: levelColors[node.level % levelColors.length],
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: sport.hasSubSports
                      ? AnimatedRotation(
                          turns: expanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: const Icon(Icons.chevron_right),
                        )
                      : null,
                ),
                Expanded(
                  child: Text(
                    sport.label,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: node.level == 1 ? FontWeight.w700 : FontWeight.w600),
                  ),
                ),
                AboBadge(sport: sport),
                const SizedBox(width: 4),
                IconButton.filledTonal(
                  tooltip: '${sport.label} öffnen',
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
