import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/feedback.dart';
import '../sport/sport.dart';
import 'organisation.dart';
import 'organisation_providers.dart';
import 'organisation_repository.dart';

/// Yes/no buttons for an event that asks for answers, with the count of all answers.
class EventResponseBar extends ConsumerStatefulWidget {
  const EventResponseBar({super.key, required this.organisation, required this.event});

  final MyOrganisation organisation;
  final SportEvent event;

  @override
  ConsumerState<EventResponseBar> createState() => _EventResponseBarState();
}

class _EventResponseBarState extends ConsumerState<EventResponseBar> {
  /// Shown right away while the answer is saved.
  EventAnswer? _pending;

  Future<void> _answer(EventAnswer answer) async {
    HapticFeedback.selectionClick();
    final organisationId = widget.organisation.id;
    setState(() => _pending = answer);
    try {
      await ref.read(organisationRepositoryProvider).answer(organisationId, widget.event.id, answer);
      ref.invalidate(eventResponsesProvider(organisationId));
      await ref.read(eventResponsesProvider(organisationId).future);
    } on Exception catch (e) {
      if (mounted) showMessage(context, 'Antwort konnte nicht gespeichert werden: ${errorText(e)}');
    }
    if (mounted) setState(() => _pending = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = ref.watch(eventResponsesProvider(widget.organisation.id)).value?[widget.event.id];
    final answer = _pending ?? summary?.myAnswer;
    final counts = summary == null
        ? null
        : Text(
            '${summary.yes} Ja · ${summary.no} Nein · ${summary.open} offen',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          );

    return Row(
      children: [
        Expanded(
          child: switch ((counts, summary?.members)) {
            (null, _) => const SizedBox.shrink(),
            (final counts?, null) => counts,
            (final counts?, final members?) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _showMembers(context, members),
                icon: const Icon(Icons.groups_outlined, size: 18),
                label: counts,
              ),
            ),
          },
        ),
        SegmentedButton<EventAnswer>(
          segments: const [
            ButtonSegment(value: EventAnswer.yes, label: Text('Ja'), icon: Icon(Icons.check)),
            ButtonSegment(value: EventAnswer.no, label: Text('Nein'), icon: Icon(Icons.close)),
          ],
          selected: {?answer},
          // No answer yet; tapping the chosen answer again keeps it
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          onSelectionChanged: (selection) {
            if (selection.isNotEmpty) _answer(selection.first);
          },
        ),
      ],
    );
  }

  void _showMembers(BuildContext context, List<({String name, EventAnswer? answer})> members) {
    final colors = Theme.of(context).colorScheme;
    final sections = [
      (label: 'Zusagen', answer: EventAnswer.yes, icon: Icon(Icons.check_circle, color: colors.primary)),
      (label: 'Absagen', answer: EventAnswer.no, icon: Icon(Icons.cancel, color: colors.error)),
      (label: 'Offen', answer: null, icon: Icon(Icons.help_outline, color: colors.outline)),
    ];
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text(widget.event.name, style: Theme.of(context).textTheme.titleLarge),
            for (final section in sections) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4),
                child: Text(
                  '${section.label} (${members.where((m) => m.answer == section.answer).length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              for (final member in members.where((m) => m.answer == section.answer))
                ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: section.icon, title: Text(member.name)),
            ],
          ],
        ),
      ),
    );
  }
}
