import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/env.dart';
import '../../core/analytics/analytics.dart';
import '../../core/widgets/feedback.dart';
import '../sync_config/sync_config.dart';
import 'calendar_links.dart';
import 'open_in_browser.dart';

Future<void> showCalendarSheet(BuildContext context, WidgetRef ref, SyncConfig config) {
  ref.read(analyticsProvider).event('calendar-modal-open');
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => CalendarSheet(config: config),
  );
}

class CalendarSheet extends ConsumerWidget {
  const CalendarSheet({super.key, required this.config});

  final SyncConfig config;

  static const _icons = {
    CalendarProvider.apple: Icons.apple,
    CalendarProvider.google: Icons.event,
    CalendarProvider.outlook: Icons.mail_outline,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = calendarFeedAddress(Env.backendUrl, config.id);
    final android = defaultTargetPlatform == TargetPlatform.android;
    final primary = android ? CalendarProvider.google : CalendarProvider.apple;
    final others = CalendarProvider.values.where((p) => p != primary);

    Future<void> open(CalendarProvider provider) async {
      ref.read(analyticsProvider).event('calendar-add', {'provider': provider.name});
      final uri = calendarSubscribeUri(provider, feed);
      final opened = android && provider == CalendarProvider.google
          // The Google Calendar app would claim the link, but only the website can subscribe
          ? await openInBrowser(uri)
          : await launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
      if (!opened && context.mounted) {
        showMessage(context, '${provider.label} konnte nicht geöffnet werden. Kopiere stattdessen den Link.');
      }
    }

    Future<void> copyLink() async {
      ref.read(analyticsProvider).event('calendar-add', {'provider': 'copy'});
      await Clipboard.setData(ClipboardData(text: 'https://$feed'));
      if (context.mounted) showMessage(context, 'Link kopiert');
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Kalender hinzufügen', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Abonniere "${config.name}" in deinem Kalender. Neue und geänderte Spiele erscheinen dort automatisch.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: () => open(primary),
              icon: Icon(_icons[primary]),
              label: Text('Zu ${primary.label} hinzufügen'),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: const Text('Weitere Optionen'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: [
                for (final provider in others)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      onPressed: () => open(provider),
                      icon: Icon(_icons[provider]),
                      label: Text(provider.label),
                    ),
                  ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: copyLink,
                  icon: const Icon(Icons.link),
                  label: const Text('Link manuell kopieren'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
