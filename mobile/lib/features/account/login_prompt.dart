import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';

Future<void> login(BuildContext context, WidgetRef ref, {bool signup = false}) async {
  if (!ref.read(authServiceProvider).isConfigured) {
    showMessage(context, 'Die Anmeldung ist in diesem Build nicht eingerichtet (AUTH0_CLIENT_ID fehlt).');
    return;
  }
  final controller = ref.read(authControllerProvider.notifier);
  try {
    await controller.login(signup: signup);
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, errorText(e));
  }
}

Future<void> showLoginPrompt(BuildContext context, WidgetRef ref, {required String message}) async {
  final choice = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Anmelden'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Später')),
        OutlinedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Konto erstellen')),
        FilledButton(onPressed: () => Navigator.pop(context, false), child: const Text('Anmelden')),
      ],
    ),
  );
  if (choice == null || !context.mounted) return;
  await login(context, ref, signup: choice);
}

class LoginRequiredView extends ConsumerWidget {
  const LoginRequiredView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Du bist noch nicht angemeldet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(onPressed: () => login(context, ref), child: const Text('Anmelden')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => login(context, ref, signup: true), child: const Text('Konto erstellen')),
        ],
      ),
    ),
  );
}
