import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
import '../account/login_prompt.dart';
import 'abo_toggle.dart';
import 'sync_config.dart';
import 'sync_config_providers.dart';

/// Something that can be in an Abo: a sport, team, event or Top Event.
class AboItem {
  const AboItem({
    required this.label,
    required this.contains,
    required this.add,
    required this.remove,
    this.coveredBy,
    this.blockedReason,
    this.analytics = const {},
  });

  /// Its name in messages, e.g. "FC Basel hinzugefügt".
  final String label;

  /// Whether the Abo holds the item itself.
  final bool Function(SyncConfig config) contains;

  /// What else brings the item into the Abo, e.g. its whole sport; null if nothing does.
  final String? Function(SyncConfig config)? coveredBy;

  /// Why the item cannot be added, e.g. all Top Events used; null if it can.
  final String? Function(SyncConfig config)? blockedReason;

  final SyncConfig Function(SyncConfig config) add;
  final SyncConfig Function(SyncConfig config) remove;

  /// Data of the subscription-add and subscription-remove analytics events.
  final Map<String, Object?> analytics;

  bool isIn(SyncConfig config) => contains(config) || coveredBy?.call(config) != null;
}

/// Adds or removes [item]. With one Abo a tap does it right away, with several the user picks them in a sheet.
Future<void> chooseAbos(BuildContext context, WidgetRef ref, AboItem item) async {
  if (ref.read(authControllerProvider).value == null) {
    await showLoginPrompt(
      context,
      ref,
      message: 'Melde dich an, um Sportarten, Teams und Events in deinem Abo zu speichern.',
    );
    return;
  }
  final configs = await ref.read(syncConfigsProvider.future);
  if (!context.mounted) return;
  switch (configs) {
    case []:
      final created = await createAbo(context, ref);
      if (created != null && context.mounted) await addToAbo(context, ref, created, item);
    case [final config] when item.contains(config):
      await removeItemFromAbo(context, ref, config, item);
    case [final config] when item.coveredBy?.call(config) != null:
      showMessage(context, 'Schon über ${item.coveredBy!(config)} im Abo enthalten');
    case [final config] when item.blockedReason?.call(config) != null:
      showMessage(context, item.blockedReason!(config)!);
    case [final config]:
      await addToAbo(context, ref, config, item);
    default:
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => AboPickerSheet(item: item),
      );
  }
}

/// Saves [item] into [config] or out of it; throws when saving fails.
Future<void> saveAboItem(WidgetRef ref, SyncConfig config, AboItem item, {required bool add}) async {
  await ref.read(syncConfigsProvider.notifier).save(add ? item.add(config) : item.remove(config));
  ref.read(analyticsProvider).event(add ? 'subscription-add' : 'subscription-remove', item.analytics);
}

Future<bool> addToAbo(BuildContext context, WidgetRef ref, SyncConfig config, AboItem item) async {
  try {
    await saveAboItem(ref, config, item, add: true);
    if (context.mounted) showMessage(context, '${item.label} hinzugefügt');
    return true;
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, errorText(e));
    return false;
  }
}

Future<void> removeItemFromAbo(BuildContext context, WidgetRef ref, SyncConfig config, AboItem item) => removeFromAbo(
  context,
  ref,
  config,
  change: item.remove,
  message: '${item.label} entfernt',
  onRemoved: () => ref.read(analyticsProvider).event('subscription-remove', item.analytics),
);

Future<void> removeFromAbo(
  BuildContext context,
  WidgetRef ref,
  SyncConfig config, {
  required SyncConfig Function(SyncConfig config) change,
  required String message,
  VoidCallback? onRemoved,
}) async {
  final controller = ref.read(syncConfigsProvider.notifier);
  try {
    await controller.save(change(config));
    if (!context.mounted) return;
    onRemoved?.call();
    showMessage(
      context,
      message,
      action: SnackBarAction(label: 'Rückgängig', onPressed: () => controller.save(config).ignore()),
    );
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, errorText(e));
  }
}

Future<SyncConfig?> createAbo(BuildContext context, WidgetRef ref) async {
  final name = await showNameDialog(context, title: 'Neues Abo erstellen', confirmLabel: 'Erstellen');
  if (name == null || !context.mounted) return null;
  try {
    final created = await ref.read(syncConfigsProvider.notifier).create(name);
    if (!context.mounted) return created;
    ref.read(analyticsProvider).event('abo-create');
    showMessage(context, 'Abo "$name" erstellt. Du kannst jetzt Sportarten, Teams und Events hinzufügen.');
    return created;
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, errorText(e));
    return null;
  }
}

Future<void> renameAbo(BuildContext context, WidgetRef ref, SyncConfig config) async {
  final name = await showNameDialog(
    context,
    title: 'Abo umbenennen',
    confirmLabel: 'Speichern',
    initialName: config.name,
  );
  if (name == null || name == config.name || !context.mounted) return;
  try {
    await ref.read(syncConfigsProvider.notifier).save(config.copyWith(name: name));
    if (context.mounted) showMessage(context, 'Abo umbenannt');
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, errorText(e));
  }
}

Future<void> deleteAbo(BuildContext context, WidgetRef ref, SyncConfig config) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'Abo "${config.name}" löschen',
    message: 'Willst du das Abo wirklich löschen? Abonnierte Kalender werden danach nicht mehr aktualisiert.',
    confirmLabel: 'Löschen',
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  try {
    await ref.read(syncConfigsProvider.notifier).delete(config);
    if (!context.mounted) return;
    ref.read(analyticsProvider).event('abo-delete');
    showMessage(context, 'Abo gelöscht');
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, errorText(e));
  }
}
