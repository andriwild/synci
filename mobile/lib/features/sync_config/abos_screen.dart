import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                        itemBuilder: (context, index) => _AboCard(
                          key: ValueKey(list[index].id),
                          config: list[index],
                          initiallyExpanded: list.length == 1,
                        ),
                      ),
              ),
            ),
    );
  }
}

enum _AboAction { rename, delete }

class _AboCard extends ConsumerStatefulWidget {
  const _AboCard({super.key, required this.config, required this.initiallyExpanded});

  final SyncConfig config;

  /// A single Abo starts open; several start closed, so the list shows all of them.
  final bool initiallyExpanded;

  @override
  ConsumerState<_AboCard> createState() => _AboCardState();
}

class _AboCardState extends ConsumerState<_AboCard> {
  late var _expanded = widget.initiallyExpanded;

  String get _count => switch (widget.config.itemCount) {
    0 => 'Leer',
    1 => '1 Eintrag',
    final n => '$n Einträge',
  };

  /// The first entries, e.g. "Super League, Formel 1, ZSC Lions +3".
  String? get _preview {
    final config = widget.config;
    final names = [
      for (final sport in config.sports) sport.label,
      for (final team in config.teams) team.name,
      for (final matchup in config.matchups) matchup.name,
      for (final event in config.events) event.name,
    ];
    if (names.isEmpty) return null;
    const shown = 3;
    return [names.take(shown).join(', '), if (names.length > shown) '+${names.length - shown}'].join(' ');
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;
    final preview = _preview;
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline);

    return Material(
      color: SynciColors.container,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _expanded,
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(config.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            _expanded || preview == null ? _count : '$_count · $preview',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle,
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: const Icon(Icons.expand_more),
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
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AboItemsList(config: config),
                        const SizedBox(height: 16),
                        Center(
                          child: FilledButton.icon(
                            onPressed: () => showCalendarSheet(context, ref, config),
                            icon: const Icon(Icons.event_available),
                            label: const Text('Zum Kalender hinzufügen'),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
