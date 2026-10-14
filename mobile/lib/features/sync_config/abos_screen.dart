import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
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

class _AboCard extends ConsumerWidget {
  const _AboCard({required this.config});

  final SyncConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(activeSyncConfigProvider)?.id == config.id;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(config.name, style: Theme.of(context).textTheme.titleMedium)),
                if (isActive) const Chip(label: Text('Aktiv'), visualDensity: VisualDensity.compact),
                IconButton(
                  tooltip: 'Abo umbenennen',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => renameAbo(context, ref, config),
                ),
                IconButton(
                  tooltip: 'Abo löschen',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => deleteAbo(context, ref, config),
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
      ),
    );
  }
}
