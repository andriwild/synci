import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/widgets/feedback.dart';
import '../sync_config/active_abo_bar.dart';
import 'sport.dart';
import 'sport_providers.dart';

const levelColors = [Color(0xFFB2BDCF), Color(0xFFC5CDD9), Color(0xFFD8DEE6), Color(0xFFE9EDF0), Color(0xFFF2F4F6)];

class SportTreeScreen extends ConsumerStatefulWidget {
  const SportTreeScreen({super.key});

  @override
  ConsumerState<SportTreeScreen> createState() => _SportTreeScreenState();
}

class _SportTreeScreenState extends ConsumerState<SportTreeScreen> {
  final _expanded = <String>{};

  void _openDetail(SportNode node) {
    ref.read(analyticsProvider).event('sport-select', {'sport': node.sport.label, 'level': node.level});
    context.go('/sport/${node.sport.id}');
  }

  List<SportNode> _visibleNodes(List<Sport> sports, [int level = 0]) => [
    for (final sport in sports) ...[
      (sport: sport, level: level),
      if (_expanded.contains(sport.id)) ..._visibleNodes(sport.subSports, level + 1),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final sports = ref.watch(sportsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 28, semanticLabel: 'Synci'),
      ),
      bottomNavigationBar: const ActiveAboBar(),
      body: sports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(sportsProvider)),
        data: (list) {
          if (list.isEmpty) return const EmptyView(icon: Icons.search_off, message: 'Keine Sportarten gefunden');
          final nodes = _visibleNodes(list);
          return RefreshIndicator(
            onRefresh: () => ref.refresh(sportsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: nodes.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: Text(
                      'Wähle eine Sportart, Liga oder ein Team und füge es deinem Abo hinzu.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final node = nodes[index - 1];
                return _SportRow(
                  node: node,
                  expanded: _expanded.contains(node.sport.id),
                  onTap: node.sport.hasSubSports
                      ? () => setState(() {
                          if (!_expanded.remove(node.sport.id)) _expanded.add(node.sport.id);
                        })
                      : () => _openDetail(node),
                  onOpen: () => _openDetail(node),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SportRow extends StatelessWidget {
  const _SportRow({required this.node, required this.expanded, required this.onTap, required this.onOpen});

  final SportNode node;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final sport = node.sport;
    return Padding(
      padding: EdgeInsets.only(left: 16.0 * node.level, bottom: 6),
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
                        ?.copyWith(fontWeight: node.level == 0 ? FontWeight.w700 : FontWeight.w600),
                  ),
                ),
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
