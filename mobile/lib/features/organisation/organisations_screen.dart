import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
import '../account/login_prompt.dart';
import 'organisation.dart';
import 'organisation_actions.dart';
import 'organisation_providers.dart';
import 'organisation_repository.dart';

class OrganisationsScreen extends ConsumerWidget {
  const OrganisationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final loggedIn = user.value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Organisationen'),
        actions: [
          if (loggedIn) ...[
            IconButton(
              tooltip: 'Organisationen entdecken',
              icon: const Icon(Icons.explore_outlined),
              onPressed: () => context.go('/organisationen/entdecken'),
            ),
            IconButton(
              tooltip: 'Organisation erstellen',
              icon: const Icon(Icons.add),
              onPressed: () => showCreateOrganisationDialog(context, ref),
            ),
          ],
        ],
      ),
      body: user.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !loggedIn
          ? const LoginRequiredView(
              message: 'Melde dich an, um deine Organisationen zu sehen oder eine Organisation zu erstellen',
            )
          : const _OrganisationList(),
    );
  }
}

class _OrganisationList extends ConsumerWidget {
  const _OrganisationList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organisations = ref.watch(myOrganisationsProvider);
    return organisations.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(error: error, onRetry: () => ref.invalidate(myOrganisationsProvider)),
      data: (list) => RefreshIndicator(
        onRefresh: () => ref.refresh(myOrganisationsProvider.future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Organisationen findest du im Tab Sportarten zuoberst. Dort siehst du die Events und kannst sie abonnieren.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 12),
            for (final organisation in list) _OrganisationCard(organisation: organisation),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Organisation erstellen'),
                onTap: () => showCreateOrganisationDialog(context, ref),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.go('/organisationen/entdecken'),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Organisationen entdecken'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrganisationCard extends ConsumerWidget {
  const _OrganisationCard({required this.organisation});

  final MyOrganisation organisation;

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final pending = organisation.isPending;
    final confirmed = await showConfirmDialog(
      context,
      title: pending ? 'Anfrage zurückziehen?' : '"${organisation.name}" verlassen?',
      message: organisation.isAdmin
          ? 'Der letzte Admin kann die Organisation nicht verlassen.'
          : pending
          ? 'Deine Beitrittsanfrage wird gelöscht.'
          : 'Du siehst danach die Events dieser Organisation nicht mehr.',
      confirmLabel: pending ? 'Zurückziehen' : 'Verlassen',
    );
    if (!confirmed || !context.mounted) return;
    await runOrganisationAction(
      context,
      () => ref.read(organisationRepositoryProvider).leave(organisation.id),
      success: pending ? 'Anfrage zurückgezogen' : 'Organisation verlassen',
      failure: 'Verlassen nicht möglich',
      onSuccess: () =>
          refreshOrganisations(ref, discover: true, members: organisation.id, syncConfigs: true, events: true),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '"${organisation.name}" löschen?',
      message: 'Alle Gruppen, Events und Mitgliedschaften werden gelöscht.',
      confirmLabel: 'Löschen',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await runOrganisationAction(
      context,
      () => ref.read(organisationRepositoryProvider).delete(organisation.id),
      success: '"${organisation.name}" wurde mit allen Gruppen und Events gelöscht.',
      failure: 'Löschen nicht möglich',
      onSuccess: () => refreshOrganisations(ref, discover: true, events: true, syncConfigs: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groups = organisation.groups.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.apartment, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    organisation.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: organisation.isPending
                  ? [const StatusChip(label: 'Anfrage ausstehend', color: Colors.orange)]
                  : [
                      StatusChip(label: organisation.role.label, color: theme.colorScheme.primary),
                      StatusChip(label: '$groups Gruppen', color: theme.colorScheme.outline),
                    ],
            ),
            if (organisation.description case final description? when description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
            if (organisation.isPending) ...[
              const SizedBox(height: 8),
              Text(
                'Ein Admin muss deine Anfrage freigeben, bevor du die Events siehst.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
            const SizedBox(height: 4),
            Wrap(
              children: [
                if (!organisation.isPending) ...[
                  TextButton.icon(
                    onPressed: () => context.go('/sport/${organisation.sport.id}'),
                    icon: const Icon(Icons.event_outlined),
                    label: const Text('Events'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/organisationen/${organisation.id}/mitglieder'),
                    icon: const Icon(Icons.people_outline),
                    label: const Text('Mitglieder'),
                  ),
                ],
                TextButton.icon(
                  onPressed: () => _leave(context, ref),
                  icon: const Icon(Icons.logout),
                  label: Text(organisation.isPending ? 'Zurückziehen' : 'Verlassen'),
                ),
                if (organisation.isAdmin)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    onPressed: () => _delete(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Löschen'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
  );
}

Future<void> showCreateOrganisationDialog(BuildContext context, WidgetRef ref) async {
  final result = await showDialog<({String name, String? description})>(
    context: context,
    builder: (_) => const _CreateOrganisationDialog(),
  );
  if (result == null || !context.mounted) return;
  await runOrganisationAction(
    context,
    () => ref.read(organisationRepositoryProvider).create(name: result.name, description: result.description),
    success: 'Organisation erstellt. Du bist jetzt Admin und kannst Gruppen und Events erfassen.',
    failure: 'Organisation konnte nicht erstellt werden',
    onSuccess: () => refreshOrganisations(ref, discover: true),
  );
}

class _CreateOrganisationDialog extends StatefulWidget {
  const _CreateOrganisationDialog();

  @override
  State<_CreateOrganisationDialog> createState() => _CreateOrganisationDialogState();
}

class _CreateOrganisationDialogState extends State<_CreateOrganisationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final description = _description.text.trim();
    Navigator.pop(context, (name: _name.text.trim(), description: description.isEmpty ? null : description));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Neue Organisation erstellen'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Du wirst automatisch Admin der neuen Organisation.'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name der Organisation', hintText: 'z.B. FC Beispiel'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Bitte Name der Organisation eingeben';
                if (value.trim().length > 100) return 'Höchstens 100 Zeichen';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Beschreibung',
                hintText: 'Optional: Worum geht es in dieser Organisation?',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
      FilledButton(onPressed: _submit, child: const Text('Erstellen')),
    ],
  );
}
