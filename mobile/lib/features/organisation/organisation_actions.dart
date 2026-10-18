import 'package:flutter/material.dart';

import '../../core/widgets/feedback.dart';

/// Runs a mutation and reports the outcome; returns whether it succeeded.
Future<bool> runOrganisationAction(
  BuildContext context,
  Future<void> Function() action, {
  required String success,
  required String failure,
  VoidCallback? onSuccess,
}) async {
  try {
    await action();
  } on Exception catch (e) {
    if (context.mounted) showMessage(context, '$failure: ${errorText(e)}');
    return false;
  }
  if (!context.mounted) return true;
  onSuccess?.call();
  showMessage(context, success);
  return true;
}
