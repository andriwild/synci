import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_service.dart';
import '../../core/widgets/feedback.dart';
import 'info_screens.dart';
import 'login_prompt.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final isConfigured = ref.watch(authServiceProvider).isConfigured;

    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: switch (user) {
                AsyncValue(isLoading: true) => const Center(child: CircularProgressIndicator()),
                AsyncValue(value: final AppUser current) => _LoggedIn(user: current),
                _ => _LoggedOut(isConfigured: isConfigured),
              },
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.auto_stories_outlined),
            title: const Text('So funktioniert Synci'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/konto/einfuehrung'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Häufige Fragen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/konto/faq'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Datenschutz'),
            trailing: const Icon(Icons.open_in_new),
            onTap: openPrivacyPolicy,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Impressum'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/konto/impressum'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Lizenzen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context, applicationName: 'Synci'),
          ),
        ],
      ),
    );
  }
}

class _LoggedOut extends ConsumerWidget {
  const _LoggedOut({required this.isConfigured});

  final bool isConfigured;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Mit einem Konto speicherst du deine Abos und abonnierst sie in deinem Kalender.'),
      const SizedBox(height: 16),
      if (!isConfigured)
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text('Die Anmeldung ist in diesem Build nicht eingerichtet (AUTH0_CLIENT_ID fehlt).'),
        ),
      FilledButton(onPressed: isConfigured ? () => login(context, ref) : null, child: const Text('Anmelden')),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: isConfigured ? () => login(context, ref, signup: true) : null,
        child: const Text('Konto erstellen'),
      ),
    ],
  );
}

class _LoggedIn extends ConsumerWidget {
  const _LoggedIn({required this.user});

  final AppUser user;

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } on Exception catch (e) {
      if (context.mounted) showMessage(context, errorText(e));
    }
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Konto löschen',
      message:
          'Willst du dein Konto wirklich löschen? Alle deine Abos werden gelöscht und abonnierte Kalender '
          'werden nicht mehr aktualisiert. Das lässt sich nicht rückgängig machen.',
      confirmLabel: 'Endgültig löschen',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (context.mounted) showMessage(context, 'Dein Konto wurde gelöscht.');
    } on Exception catch (e) {
      if (context.mounted) showMessage(context, 'Konto konnte nicht gelöscht werden. ${errorText(e)}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picture = user.pictureUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              foregroundImage: picture == null ? null : NetworkImage(picture.toString()),
              child: const Icon(Icons.person_outline),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.name != null && user.name != user.email)
                    Text(user.name!, style: Theme.of(context).textTheme.titleMedium),
                  if (user.email != null) Text(user.email!),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: () => _logout(context, ref), child: const Text('Abmelden')),
        const SizedBox(height: 8),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          onPressed: () => _deleteAccount(context, ref),
          child: const Text('Konto löschen'),
        ),
      ],
    );
  }
}
