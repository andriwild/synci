import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../theme.dart';
import '../account/login_prompt.dart';
import '../calendar/calendar_sheet.dart';
import 'abo_actions.dart';
import 'abo_items_list.dart';
import 'sync_config_providers.dart';

/// Floating bar above the tabs with the active Abo; opens it to see, switch or subscribe to it.
class ActiveAboBar extends ConsumerWidget {
  const ActiveAboBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authControllerProvider).value;
    final configs = ref.watch(syncConfigsProvider);
    final active = ref.watch(activeSyncConfigProvider);
    final action = FilledButton.styleFrom(backgroundColor: SynciColors.highlight, foregroundColor: colors.onSurface);

    final Widget content;
    if (user == null) {
      content = ListTile(
        title: const Text('Melde dich an, um Abos zu speichern'),
        trailing: FilledButton(style: action, onPressed: () => login(context, ref), child: const Text('Anmelden')),
      );
    } else if (active == null) {
      content = configs.isLoading
          ? const Padding(padding: EdgeInsets.all(24), child: LinearProgressIndicator())
          : ListTile(
              title: const Text('Noch kein Abo vorhanden'),
              trailing: FilledButton(
                style: action,
                onPressed: () => createAbo(context, ref),
                child: const Text('Erstellen'),
              ),
            );
    } else {
      content = ListTile(
        onTap: () {
          HapticFeedback.selectionClick();
          showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => const _ActiveAboSheet(),
          );
        },
        leading: _CountBadge(count: active.itemCount),
        title: Text(
          active.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('Aktives Abo', style: TextStyle(color: colors.onPrimary.withValues(alpha: 0.75))),
        trailing: const Icon(Icons.expand_less),
      );
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Material(
          color: colors.primary,
          elevation: 3,
          shadowColor: Colors.black38,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: ListTileTheme.merge(textColor: colors.onPrimary, iconColor: colors.onPrimary, child: content),
        ),
      ),
    );
  }
}

/// Calendar with the number of items; the number pops when it changes.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Badge(
    backgroundColor: SynciColors.highlight,
    textColor: Theme.of(context).colorScheme.onSurface,
    label: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: child,
      ),
      child: Text('$count', key: ValueKey(count)),
    ),
    child: const Icon(Icons.calendar_month_outlined),
  );
}

class _ActiveAboSheet extends ConsumerWidget {
  const _ActiveAboSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeSyncConfigProvider);
    final configs = ref.watch(syncConfigsProvider).value ?? const [];
    if (active == null) return const SizedBox(height: 120);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          Text('Aktives Abo', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              spacing: 8,
              children: [
                for (final config in configs)
                  ChoiceChip(
                    label: Text(config.name),
                    selected: config.id == active.id,
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      ref.read(activeSyncConfigIdProvider.notifier).select(config.id);
                    },
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add),
                  label: const Text('Neues Abo'),
                  onPressed: () => createAbo(context, ref),
                ),
              ],
            ),
          ),
          AboItemsList(config: active),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => showCalendarSheet(context, ref, active),
            icon: const Icon(Icons.event_available),
            label: const Text('Zum Kalender hinzufügen'),
          ),
        ],
      ),
    );
  }
}
