import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/feedback.dart';
import '../sport/sport.dart';
import '../sport/sport_providers.dart';
import 'event_form_screen.dart';
import 'event_responses.dart';
import 'organisation.dart';
import 'organisation_actions.dart';
import 'organisation_providers.dart';
import 'organisation_repository.dart';
import 'organisations_screen.dart';

/// Role, node type and, for admins, the management actions of an organisation node.
class OrganisationToolbar extends ConsumerWidget {
  const OrganisationToolbar({super.key, required this.organisation, required this.sport});

  final MyOrganisation organisation;
  final Sport sport;

  bool get _isGroup => sport.id != organisation.sport.id;

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final name = await showNameDialog(
      context,
      title: 'Neue Gruppe erstellen',
      message: 'Gruppen sind z.B. Mannschaften oder Abteilungen. Mitglieder können einzelne Gruppen abonnieren.',
      confirmLabel: 'Erstellen',
      label: 'Gruppenname',
      hint: 'z.B. 1. Mannschaft',
      emptyError: 'Bitte Gruppennamen eingeben',
      maxLength: 100,
    );
    if (name == null || !context.mounted) return;
    await runOrganisationAction(
      context,
      () => ref.read(organisationRepositoryProvider).createGroup(organisation.id, name),
      success: 'Die Gruppe "$name" wurde erstellt.',
      failure: 'Gruppe konnte nicht erstellt werden',
      onSuccess: () => refreshOrganisations(ref),
    );
  }

  Future<void> _renameGroup(BuildContext context, WidgetRef ref) async {
    final name = await showNameDialog(
      context,
      title: 'Gruppe umbenennen',
      confirmLabel: 'Speichern',
      initialName: sport.label,
      label: 'Gruppenname',
      emptyError: 'Bitte Gruppennamen eingeben',
      maxLength: 100,
    );
    if (name == null || name == sport.label || !context.mounted) return;
    await runOrganisationAction(
      context,
      () => ref.read(organisationRepositoryProvider).renameGroup(organisation.id, sport.id, name),
      success: 'Gruppe umbenannt',
      failure: 'Gruppe konnte nicht umbenannt werden',
      onSuccess: () => refreshOrganisations(ref),
    );
  }

  Future<void> _deleteGroup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Gruppe "${sport.label}" löschen?',
      message: 'Die Events der Gruppe bleiben erhalten und gehören danach zur ganzen Organisation.',
      confirmLabel: 'Löschen',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final deleted = await runOrganisationAction(
      context,
      () => ref.read(organisationRepositoryProvider).deleteGroup(organisation.id, sport.id),
      success: 'Gruppe gelöscht. Die Events der Gruppe gehören jetzt zur Organisation.',
      failure: 'Gruppe konnte nicht gelöscht werden',
      onSuccess: () => refreshOrganisations(ref, events: true, syncConfigs: true),
    );
    if (deleted && context.mounted) context.go('/sport/${organisation.sport.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          StatusChip(label: organisation.role.label, color: theme.colorScheme.primary),
          StatusChip(
            label: _isGroup ? 'Gruppe von ${organisation.name}' : 'Organisation',
            color: theme.colorScheme.outline,
          ),
          if (organisation.isAdmin) ...[
            FilledButton.icon(
              onPressed: () => openEventForm(context, organisation: organisation, defaultSportId: sport.id),
              icon: const Icon(Icons.add),
              label: const Text('Event erfassen'),
            ),
            MenuAnchor(
              builder: (context, controller, _) => OutlinedButton.icon(
                onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                icon: const Icon(Icons.more_horiz),
                label: const Text('Verwalten'),
              ),
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.create_new_folder_outlined),
                  onPressed: () => _createGroup(context, ref),
                  child: const Text('Gruppe erstellen'),
                ),
                if (_isGroup) ...[
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit_outlined),
                    onPressed: () => _renameGroup(context, ref),
                    child: const Text('Gruppe umbenennen'),
                  ),
                  MenuItemButton(
                    leadingIcon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () => _deleteGroup(context, ref),
                    child: Text('Gruppe löschen', style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ],
                MenuItemButton(
                  leadingIcon: const Icon(Icons.people_outline),
                  onPressed: () => context.go('/organisationen/${organisation.id}/mitglieder'),
                  child: const Text('Mitglieder verwalten'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Upcoming events of an organisation node, grouped by day.
class OrganisationEventList extends ConsumerWidget {
  const OrganisationEventList({
    super.key,
    required this.organisation,
    required this.sport,
    required this.events,
    required this.trailing,
  });

  final MyOrganisation organisation;
  final Sport sport;
  final PagedItems<SportEvent> events;

  /// The subscribe control of an event.
  final Widget Function(SportEvent event) trailing;

  Future<void> _delete(BuildContext context, WidgetRef ref, SportEvent event) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '"${event.name}" löschen?',
      message: 'Das Event verschwindet auch aus den Kalendern der Abonnenten.',
      confirmLabel: 'Löschen',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await runOrganisationAction(
      context,
      () => ref.read(organisationRepositoryProvider).deleteEvent(organisation.id, event.id),
      success: 'Event gelöscht',
      failure: 'Event konnte nicht gelöscht werden',
      onSuccess: () => refreshOrganisations(ref, mine: false, events: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (events.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          organisation.isAdmin
              ? 'Noch keine Events. Erfasse das erste Event für deine Organisation.'
              : 'Keine kommenden Events',
        ),
      );
    }

    final groupLabels = {for (final group in organisation.groups) group.id: group.label};
    final isRoot = sport.id == organisation.sport.id;
    final children = <Widget>[];
    DateTime? day;
    for (final event in events.items) {
      final start = event.startsOn;
      if (start != null && (day == null || !DateUtils.isSameDay(day, start))) {
        day = start;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(_dayHeading(start), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ),
        );
      }
      final group = isRoot ? groupLabels[event.sportId] : null;
      final meta = [?group, if (event.location case final location? when location.isNotEmpty) location];
      final tile = ListTile(
        contentPadding: EdgeInsets.zero,
        leading: SizedBox(
          width: 64,
          child: Text(
            start == null || event.endsOn == null ? 'ganztägig' : DateFormat('HH:mm', 'de_CH').format(start),
            style: event.endsOn == null ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium,
          ),
        ),
        title: Text(event.name),
        subtitle: meta.isEmpty ? null : Text(meta.join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (organisation.isAdmin) ...[
              IconButton(
                tooltip: 'Event bearbeiten',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => openEventForm(
                  context,
                  organisation: organisation,
                  defaultSportId: event.sportId ?? sport.id,
                  event: event,
                ),
              ),
              IconButton(
                tooltip: 'Event löschen',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(context, ref, event),
              ),
            ],
            trailing(event),
          ],
        ),
      );
      children.add(
        event.responseRequested
            ? Column(
                children: [
                  tile,
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EventResponseBar(organisation: organisation, event: event),
                  ),
                ],
              )
            : tile,
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

String _dayHeading(DateTime day) {
  final pattern = day.year == DateTime.now().year ? 'EEEE, d. MMMM' : 'EEEE, d. MMMM yyyy';
  return DateFormat(pattern, 'de_CH').format(day);
}
