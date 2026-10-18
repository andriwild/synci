import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/feedback.dart';
import '../sport/sport.dart';
import 'organisation.dart';
import 'organisation_providers.dart';
import 'organisation_repository.dart';

final _dateFormat = DateFormat('EEE, d.M.yyyy', 'de_CH');

/// Opens the form; [event] is `null` for a new event.
Future<void> openEventForm(
  BuildContext context, {
  required MyOrganisation organisation,
  required String defaultSportId,
  SportEvent? event,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => EventFormScreen(organisation: organisation, defaultSportId: defaultSportId, event: event),
  ),
);

class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({super.key, required this.organisation, required this.defaultSportId, this.event});

  final MyOrganisation organisation;
  final String defaultSportId;
  final SportEvent? event;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.event?.name);
  late final _location = TextEditingController(text: widget.event?.location);
  late final _description = TextEditingController(text: widget.event?.description);
  late String _sportId = widget.event?.sportId ?? widget.defaultSportId;
  late bool _allDay = widget.event != null && widget.event!.endsOn == null;
  late DateTime _start = widget.event?.startsOn ?? _nextFullHour();
  late DateTime _end = widget.event?.endsOn ?? _start.add(const Duration(hours: 1));
  bool _saving = false;

  static DateTime _nextFullHour() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(initial.year - 1),
    lastDate: DateTime(initial.year + 5),
    locale: const Locale('de', 'CH'),
  );

  Future<TimeOfDay?> _pickTime(DateTime initial) => showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
    builder: (context, child) =>
        MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
  );

  DateTime _withDate(DateTime value, DateTime date) =>
      DateTime(date.year, date.month, date.day, value.hour, value.minute);

  DateTime _withTime(DateTime value, TimeOfDay time) =>
      DateTime(value.year, value.month, value.day, time.hour, time.minute);

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_allDay && _end.isBefore(_start)) {
      showMessage(context, 'Das Ende darf nicht vor dem Beginn liegen');
      return;
    }
    final request = OrganisationEventRequest(
      name: _name.text.trim(),
      sportId: _sportId,
      startsOn: _allDay ? DateTime(_start.year, _start.month, _start.day) : _start,
      endsOn: _allDay ? null : _end,
      location: _location.text,
      description: _description.text,
    );
    final repository = ref.read(organisationRepositoryProvider);
    setState(() => _saving = true);
    try {
      if (widget.event case final event?) {
        await repository.updateEvent(widget.organisation.id, event.id, request);
      } else {
        await repository.createEvent(widget.organisation.id, request);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showMessage(context, 'Event konnte nicht gespeichert werden: ${errorText(e)}');
      }
      return;
    }
    if (!mounted) return;
    refreshOrganisations(ref, mine: false, events: true);
    showMessage(context, widget.event == null ? 'Event erfasst' : 'Event aktualisiert');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final organisation = widget.organisation;
    final targets = [
      (id: organisation.sport.id, label: '${organisation.name} (ganze Organisation)'),
      for (final group in organisation.groups) (id: group.id, label: group.label),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Event erfassen' : 'Event bearbeiten'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Speichern'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: widget.event == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name', hintText: 'z.B. Training, Heimspiel, GV'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Bitte einen Namen eingeben';
                if (value.trim().length > 100) return 'Höchstens 100 Zeichen';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: targets.any((t) => t.id == _sportId) ? _sportId : organisation.sport.id,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Gehört zu'),
              items: [
                for (final target in targets)
                  DropdownMenuItem(
                    value: target.id,
                    child: Text(target.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) => setState(() => _sportId = value ?? _sportId),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ganztägig'),
              value: _allDay,
              onChanged: (value) => setState(() => _allDay = value),
            ),
            _DateTimeRow(
              label: 'Beginn',
              value: _start,
              showTime: !_allDay,
              onDate: () async {
                final date = await _pickDate(_start);
                if (date == null) return;
                setState(() {
                  final duration = _end.difference(_start);
                  _start = _withDate(_start, date);
                  _end = _start.add(duration);
                });
              },
              onTime: () async {
                final time = await _pickTime(_start);
                if (time == null) return;
                setState(() {
                  final duration = _end.difference(_start);
                  _start = _withTime(_start, time);
                  _end = _start.add(duration);
                });
              },
            ),
            if (!_allDay)
              _DateTimeRow(
                label: 'Ende',
                value: _end,
                showTime: true,
                error: _end.isBefore(_start) ? 'Das Ende darf nicht vor dem Beginn liegen' : null,
                onDate: () async {
                  final date = await _pickDate(_end);
                  if (date != null) setState(() => _end = _withDate(_end, date));
                },
                onTime: () async {
                  final time = await _pickTime(_end);
                  if (time != null) setState(() => _end = _withTime(_end, time));
                },
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Ort', hintText: 'z.B. Sporthalle Musterstadt'),
              validator: (value) => (value?.trim().length ?? 0) > 255 ? 'Höchstens 255 Zeichen' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Beschreibung', alignLabelWithHint: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.label,
    required this.value,
    required this.showTime,
    required this.onDate,
    required this.onTime,
    this.error,
  });

  final String label;
  final DateTime value;
  final bool showTime;
  final VoidCallback onDate;
  final VoidCallback onTime;
  final String? error;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: InputDecorator(
      decoration: InputDecoration(labelText: label, errorText: error),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
              onPressed: onDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: Text(_dateFormat.format(value)),
            ),
          ),
          if (showTime)
            TextButton.icon(
              onPressed: onTime,
              icon: const Icon(Icons.schedule, size: 18),
              label: Text(DateFormat('HH:mm', 'de_CH').format(value)),
            ),
        ],
      ),
    ),
  );
}
