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
      if (android && provider == CalendarProvider.google) {
        await showGoogleOnAndroidSteps(context, feed);
        return;
      }
      final opened = await launchUrl(
        calendarSubscribeUri(provider, feed),
        mode: LaunchMode.externalApplication,
      ).catchError((_) => false);
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

/// The Google Calendar app can't subscribe to a calendar, only the website can. So the
/// browser opens the subscribe link; the steps cover a website that doesn't add it by
/// itself (e.g. the mobile view), with the feed copied for adding it by hand.
Future<void> showGoogleOnAndroidSteps(BuildContext context, String feed) => showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(
    title: const Text('Google Kalender am Handy'),
    content: const SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Google erlaubt Kalender-Abos nur auf der Website. Wir öffnen sie im Browser, dort wird das Abo hinzugefügt.',
          ),
          SizedBox(height: 12),
          Text('Klappt das nicht von selbst:'),
          SizedBox(height: 4),
          Text('1. Im Browser-Menü ⋮ «Desktop-Website» einschalten.'),
          SizedBox(height: 4),
          Text('2. Bei «Kalender hinzufügen» auf «Hinzufügen» tippen.'),
          SizedBox(height: 12),
          Text(
            'Kein «Hinzufügen» zu sehen? Links bei «Weitere Kalender» auf + und «Per URL» tippen, '
            'den Link einfügen (er ist schon kopiert) und «Kalender hinzufügen» tippen.',
          ),
          SizedBox(height: 12),
          Text(
            'Nach ein paar Minuten ist der Kalender auch in der Google-Kalender-App. Sonst dort in den '
            'Einstellungen den Kalender antippen und «Synchronisieren» einschalten.',
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Abbrechen')),
      FilledButton(
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: 'https://$feed'));
          final opened = await openInBrowser(calendarSubscribeUri(CalendarProvider.google, feed));
          if (!dialogContext.mounted) return;
          Navigator.pop(dialogContext);
          if (!opened) showMessage(context, 'Der Browser konnte nicht geöffnet werden. Der Link ist kopiert.');
        },
        child: const Text('Google Kalender öffnen'),
      ),
    ],
  ),
);
