import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/feedback.dart';
import '../../theme.dart';
import 'app_update_providers.dart';

/// Offers a newer store version; takes no space while there is none.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key, this.padding = EdgeInsets.zero});

  /// Applied only while the banner shows.
  final EdgeInsetsGeometry padding;

  Future<void> _update(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(appUpdateRepositoryProvider).update();
    } on Exception {
      if (context.mounted) showMessage(context, 'Das Update hat nicht geklappt. Versuch es im Store.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(appUpdateAvailableProvider).value != true) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SynciColors.highlight.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          child: Row(
            spacing: 12,
            children: [
              Icon(Icons.system_update, color: theme.colorScheme.primary),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update verfügbar', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Eine neue Version von Synci ist bereit.', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () => _update(context, ref),
                child: const Text('Aktualisieren'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
