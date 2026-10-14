import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../account/login_prompt.dart';
import '../calendar/calendar_sheet.dart';
import 'abo_actions.dart';
import 'abo_items_list.dart';
import 'sync_config_providers.dart';

class ActiveAboBar extends ConsumerWidget {
  const ActiveAboBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final user = ref.watch(authControllerProvider).value;
    final configs = ref.watch(syncConfigsProvider);
    final active = ref.watch(activeSyncConfigProvider);

    final Widget content;
    if (user == null) {
      content = ListTile(
        title: const Text('Melde dich an, um Abos zu speichern'),
        trailing: FilledButton(onPressed: () => login(context, ref), child: const Text('Anmelden')),
      );
    } else if (active == null) {
      content = configs.isLoading
          ? const LinearProgressIndicator()
          : ListTile(
              title: const Text('Noch kein Abo vorhanden'),
              trailing: FilledButton(onPressed: () => createAbo(context, ref), child: const Text('Erstellen')),
            );
    } else {
      content = ListTile(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => const _ActiveAboSheet(),
        ),
        leading: Badge.count(
          count: active.itemCount,
          backgroundColor: const Color(0xFFF8E06D),
          textColor: colors.onSurface,
          child: const Icon(Icons.calendar_month_outlined),
        ),
        title: Text(active.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: const Text('Aktives Abo'),
        trailing: const Icon(Icons.expand_less),
      );
    }

    return Material(
      color: colors.surfaceContainer,
      child: SafeArea(top: false, bottom: false, child: content),
    );
  }
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
          Row(
            children: [
              Expanded(child: Text(active.name, style: Theme.of(context).textTheme.titleLarge)),
              PopupMenuButton<String>(
                tooltip: 'Abo wechseln',
                icon: const Icon(Icons.swap_horiz),
                onSelected: (id) =>
                    id.isEmpty ? createAbo(context, ref) : ref.read(activeSyncConfigIdProvider.notifier).select(id),
                itemBuilder: (_) => [
                  for (final config in configs)
                    CheckedPopupMenuItem(value: config.id, checked: config.id == active.id, child: Text(config.name)),
                  const PopupMenuDivider(),
                  const PopupMenuItem(value: '', child: Text('Neues Abo erstellen')),
                ],
              ),
            ],
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
