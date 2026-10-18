import 'package:flutter/material.dart';

import '../api/api_client.dart';

String errorText(Object error) => error is ApiException ? error.message : 'Ein unerwarteter Fehler ist aufgetreten.';

void showMessage(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('Ups, es ist ein Fehler aufgetreten', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(errorText(error), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Erneut versuchen')),
        ],
      ),
    ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error) : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String initialName = '',
  String label = 'Abo-Name',
  String emptyError = 'Bitte Abo-Namen eingeben',
  String? hint,
  String? message,
  int? maxLength,
}) => showDialog<String>(
  context: context,
  builder: (_) => _NameDialog(
    title: title,
    confirmLabel: confirmLabel,
    initialName: initialName,
    label: label,
    emptyError: emptyError,
    hint: hint,
    message: message,
    maxLength: maxLength,
  ),
);

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.label,
    required this.emptyError,
    this.hint,
    this.message,
    this.maxLength,
  });

  final String title;
  final String confirmLabel;
  final String initialName;
  final String label;
  final String emptyError;
  final String? hint;
  final String? message;
  final int? maxLength;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null) ...[Text(widget.message!), const SizedBox(height: 12)],
          TextFormField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return widget.emptyError;
              if (widget.maxLength != null && value.trim().length > widget.maxLength!) {
                return 'Höchstens ${widget.maxLength} Zeichen';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
      FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
    ],
  );
}
