import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
import '../../theme.dart';
import '../account/login_prompt.dart';
import '../calendar/calendar_sheet.dart';
import 'abo_actions.dart';
import 'abo_items_list.dart';
import 'sync_config.dart';
import 'sync_config_providers.dart';

class AbosScreen extends ConsumerWidget {
  const AbosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final configs = ref.watch(syncConfigsProvider);
    final loggedIn = user.value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Abos'),
        actions: [
          if (loggedIn)
            IconButton(
              tooltip: 'Neues Abo erstellen',
              icon: const Icon(Icons.add),
              onPressed: () => createAbo(context, ref),
            ),
        ],
      ),
      body: user.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !loggedIn
          ? const LoginRequiredView(message: 'Melde dich an, um deine Abos zu sehen.')
          : configs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(syncConfigsProvider)),
              data: (list) => RefreshIndicator(
                onRefresh: () => ref.refresh(syncConfigsProvider.future),
                child: list.isEmpty
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          EmptyView(
                            icon: Icons.event_note_outlined,
                            message: 'Keine Abos vorhanden',
                            action: FilledButton(
                              onPressed: () => createAbo(context, ref),
                              child: const Text('Neues Abo erstellen'),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _AboCard(config: list[index]),
                      ),
              ),
            ),
    );
  }
}

enum _AboAction { rename, delete }

class _AboCard extends ConsumerWidget {
  const _AboCard({required this.config});

  final SyncConfig config;

  String get _count => switch (config.itemCount) {
    0 => 'Leer',
    1 => '1 Eintrag',
    final n => '$n Einträge',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isActive = ref.watch(activeSyncConfigProvider)?.id == config.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: SynciColors.container,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? theme.colorScheme.primary : Colors.transparent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(_count, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
              ),
              _ActiveChip(
                active: isActive,
                onActivate: () {
                  HapticFeedback.selectionClick();
                  ref.read(activeSyncConfigIdProvider.notifier).select(config.id);
                },
              ),
              PopupMenuButton<_AboAction>(
                tooltip: 'Mehr',
                onSelected: (action) => switch (action) {
                  _AboAction.rename => renameAbo(context, ref, config),
                  _AboAction.delete => deleteAbo(context, ref, config),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _AboAction.rename,
                    child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Umbenennen')),
                  ),
                  PopupMenuItem(
                    value: _AboAction.delete,
                    child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Löschen')),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AboItemsList(config: config),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => showCalendarSheet(context, ref, config),
                icon: const Icon(Icons.event_available),
                label: const Text('Zum Kalender hinzufügen'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(activeSyncConfigIdProvider.notifier).select(config.id);
                  context.go('/sport');
                },
                icon: const Icon(Icons.add),
                label: const Text('Sportarten hinzufügen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Aktiv" on the active Abo, "Aktivieren" on the others to make them the active one.
class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.active, required this.onActivate});

  final bool active;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 200),
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: animation, child: child),
    ),
    child: active
        ? const Chip(
            key: ValueKey(true),
            avatar: Icon(Icons.check, size: 18),
            label: Text('Aktiv'),
            backgroundColor: SynciColors.highlight,
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
          )
        : ActionChip(
            key: const ValueKey(false),
            label: const Text('Aktivieren'),
            onPressed: onActivate,
            visualDensity: VisualDensity.compact,
          ),
  );
}
