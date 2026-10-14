import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics/analytics.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
import '../account/login_prompt.dart';
import 'sync_config.dart';
import 'sync_config_providers.dart';

Future<void> editActiveAbo(
  BuildContext context,
  WidgetRef ref, {
  required SyncConfig Function(SyncConfig active) change,
  required String message,
  VoidCallback? onSaved,
}) async {
  if (ref.read(authControllerProvider).value == null) {
    await showLoginPrompt(
      context,
      ref,
      message: 'Melde dich an, um Sportarten, Teams und Events in deinem Abo zu speichern.',
    );
    return;
  }
  var active = ref.read(activeSyncConfigProvider);
  if (active == null) {
    await ref.read(syncConfigsProvider.future);
    if (!context.mounted) return;
    active = ref.read(activeSyncConfigProvider) ?? await createAbo(context, ref);
    if (active == null) return;
  }
  try {
    await ref.read(syncConfigsProvider.notifier).save(change(active));
    if (!context.mounted) return;
    onSaved?.call();
    showMessage(context, message);
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, errorText(e));
  }
}

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
