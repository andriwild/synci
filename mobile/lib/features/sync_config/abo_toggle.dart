import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/feedback.dart';
import 'abo_actions.dart';
import 'sync_config.dart';
import 'sync_config_providers.dart';

/// A plus that turns into a check once the item is in one of my Abos; a tap adds, removes or picks the Abos.
class AboToggle extends ConsumerWidget {
  const AboToggle({super.key, required this.kind, required this.item});

  /// What the item is, e.g. `Team`, for the tooltips.
  final String kind;
  final AboItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final configs = ref.watch(syncConfigsProvider).value ?? const <SyncConfig>[];
    final inAbo = configs.any(item.isIn);
    final tooltip = switch (configs) {
      _ when !inAbo => '$kind hinzufügen',
      [final config] when !item.contains(config) => 'Schon im Abo enthalten',
      [_] => '$kind entfernen',
      _ => 'Abos für $kind wählen',
    };
    return IconButton(
      tooltip: tooltip,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
        child: inAbo
            ? Icon(Icons.check_circle, key: const ValueKey(true), color: colors.primary, semanticLabel: 'Im Abo')
            : const Icon(Icons.add_circle_outline, key: ValueKey(false)),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        chooseAbos(context, ref, item);
      },
    );
  }
}

/// Puts the item into each of my Abos or takes it out; every tap is saved right away.
class AboPickerSheet extends ConsumerStatefulWidget {
  const AboPickerSheet({super.key, required this.item});

  final AboItem item;

  @override
  ConsumerState<AboPickerSheet> createState() => _AboPickerSheetState();
}

class _AboPickerSheetState extends ConsumerState<AboPickerSheet> {
  final _saving = <String>{};

  Future<void> _set(SyncConfig config, {required bool add}) async {
    HapticFeedback.selectionClick();
    setState(() => _saving.add(config.id));
    try {
      await saveAboItem(ref, config, widget.item, add: add);
    } on Exception catch (e) {
      if (mounted) showMessage(context, errorText(e));
    }
    if (mounted) setState(() => _saving.remove(config.id));
  }

  Future<void> _createAbo() async {
    final created = await createAbo(context, ref);
    if (created != null && mounted) await _set(created, add: true);
  }

  String _count(SyncConfig config) => switch (config.itemCount) {
    0 => 'Leer',
    1 => '1 Eintrag',
    final n => '$n Einträge',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final configs = ref.watch(syncConfigsProvider).value ?? const <SyncConfig>[];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(item.label, style: theme.textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'In welchen Abos?',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final config in configs)
                    _AboOption(
                      config: config,
                      item: item,
                      count: _count(config),
                      saving: _saving.contains(config.id),
                      onChanged: (add) => _set(config, add: add),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                TextButton.icon(onPressed: _createAbo, icon: const Icon(Icons.add), label: const Text('Neues Abo')),
                const Spacer(),
                FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fertig')),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AboOption extends StatelessWidget {
  const _AboOption({
    required this.config,
    required this.item,
    required this.count,
    required this.saving,
    required this.onChanged,
  });

  final SyncConfig config;
  final AboItem item;
  final String count;
  final bool saving;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final own = item.contains(config);
    final via = item.coveredBy?.call(config);
    final blocked = own ? null : item.blockedReason?.call(config);
    return CheckboxListTile(
      value: own || via != null,
      onChanged: saving || via != null || blocked != null ? null : (value) => onChanged(value ?? false),
      title: Text(config.name),
      subtitle: Text(via != null ? 'Über $via enthalten' : blocked ?? count),
      secondary: saving ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
    );
  }
}
