import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A plus that turns into a check once the item is in the Abo; tapping the check removes it again.
class AboToggle extends StatelessWidget {
  const AboToggle({super.key, required this.inAbo, required this.label, required this.onAdd, this.onRemove});

  final bool inAbo;

  /// What the item is, e.g. `Team`, for the tooltips.
  final String label;
  final VoidCallback onAdd;

  /// Null while the item is only in the Abo through something else, e.g. its whole sport.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: child,
      ),
      child: inAbo
          ? Icon(Icons.check_circle, key: const ValueKey(true), color: colors.primary, semanticLabel: 'Im Abo')
          : const Icon(Icons.add_circle_outline, key: ValueKey(false)),
    );
    final onRemove = this.onRemove;
    if (inAbo && onRemove == null) {
      return Tooltip(
        message: 'Schon im Abo enthalten',
        child: Padding(padding: const EdgeInsets.all(12), child: icon),
      );
    }
    return IconButton(
      tooltip: inAbo ? '$label entfernen' : '$label hinzufügen',
      icon: icon,
      onPressed: () {
        HapticFeedback.lightImpact();
        inAbo ? onRemove!() : onAdd();
      },
    );
  }
}
