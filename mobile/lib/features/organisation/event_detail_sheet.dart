import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/feedback.dart';
import '../sport/sport.dart';
import 'event_responses.dart';
import 'organisation.dart';

/// Everything about an organisation event: time, place, description, answers and Abo; admins also edit and delete.
Future<void> showEventDetailSheet(
  BuildContext context, {
  required MyOrganisation organisation,
  required SportEvent event,
  required Widget aboToggle,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _EventDetailSheet(
    organisation: organisation,
    event: event,
    aboToggle: aboToggle,
    onEdit: onEdit,
    onDelete: onDelete,
  ),
);

class _EventDetailSheet extends StatelessWidget {
  const _EventDetailSheet({
    required this.organisation,
    required this.event,
    required this.aboToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final MyOrganisation organisation;
  final SportEvent event;
  final Widget aboToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String? get _when {
    final start = event.startsOn;
    if (start == null) return null;
    final day = DateFormat('EEEE, d. MMMM yyyy', 'de_CH').format(start);
    final end = event.endsOn;
    if (end == null) return '$day · ganztägig';
    final time = DateFormat('HH:mm', 'de_CH');
    return '$day · ${time.format(start)}–${time.format(end)}';
  }

  Future<void> _openMap(BuildContext context, String location) async {
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.https('maps.apple.com', '/', {'q': location})
        : Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': location});
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
    if (!opened && context.mounted) showMessage(context, 'Die Karte konnte nicht geöffnet werden');
  }

  void _close(BuildContext context, VoidCallback then) {
    Navigator.of(context).pop();
    then();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = organisation.groups.where((g) => g.id == event.sportId).firstOrNull?.label;
    final when = _when;
    final location = event.location;
    final description = event.description;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        group ?? organisation.name,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                aboToggle,
              ],
            ),
            const SizedBox(height: 12),
            if (when != null) _InfoRow(icon: Icons.schedule, text: when),
            if (location != null && location.isNotEmpty)
              _InfoRow(
                icon: Icons.place_outlined,
                text: location,
                tooltip: 'Auf der Karte zeigen',
                onTap: () => _openMap(context, location),
              ),
            if (description != null && description.isNotEmpty) _InfoRow(icon: Icons.notes, text: description),
            if (event.responseRequested) ...[
              const Divider(height: 32),
              Text('Zu- und Absagen', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              EventResponseBar(organisation: organisation, event: event),
            ],
            if (organisation.isAdmin) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _close(context, onEdit),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Bearbeiten'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                    onPressed: () => _close(context, onDelete),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Löschen'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.onTap, this.tooltip});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final row = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Icon(icon, size: 20, color: colors.primary),
            Expanded(
              child: Text(
                text,
                style: onTap == null ? null : TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
              ),
            ),
            if (onTap != null) Icon(Icons.open_in_new, size: 18, color: colors.primary),
          ],
        ),
      ),
    );
    return tooltip == null ? row : Tooltip(message: tooltip, child: row);
  }
}
