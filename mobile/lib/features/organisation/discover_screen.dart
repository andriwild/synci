import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/feedback.dart';
import 'organisation.dart';
import 'organisation_actions.dart';
import 'organisation_providers.dart';
import 'organisation_repository.dart';
import 'organisations_screen.dart';

class DiscoverOrganisationsScreen extends ConsumerStatefulWidget {
  const DiscoverOrganisationsScreen({super.key});

  @override
  ConsumerState<DiscoverOrganisationsScreen> createState() => _DiscoverOrganisationsScreenState();
}

class _DiscoverOrganisationsScreenState extends ConsumerState<DiscoverOrganisationsScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _search = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => setState(() => _search = value.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(discoverProvider(_search));

    return Scaffold(
      appBar: AppBar(title: const Text('Organisationen entdecken')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text(
            'Frage den Beitritt an. Nach der Freigabe durch einen Admin erscheint die Organisation zuoberst im Tab '
            'Sportarten und du siehst ihre Events.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Organisation suchen',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Suche löschen',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          ...results.when(
            loading: () => const [
              Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => [ErrorView(error: error, onRetry: () => ref.invalidate(discoverProvider(_search)))],
            data: (paged) => [
              if (paged.items.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _search.isEmpty ? 'Noch keine Organisationen vorhanden' : 'Keine Organisation gefunden',
                    textAlign: TextAlign.center,
                  ),
                ),
              for (final organisation in paged.items) _DiscoverTile(organisation: organisation),
              if (paged.hasMore)
                Center(
                  child: TextButton.icon(
                    onPressed: paged.isLoadingMore
                        ? null
                        : () => ref.read(discoverProvider(_search).notifier).loadMore().catchError((Object e) {
                            if (context.mounted) showMessage(context, errorText(e));
                          }),
                    icon: const Icon(Icons.add),
                    label: const Text('Mehr anzeigen'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscoverTile extends ConsumerStatefulWidget {
  const _DiscoverTile({required this.organisation});

  final OrganisationSummary organisation;

  @override
  ConsumerState<_DiscoverTile> createState() => _DiscoverTileState();
}

class _DiscoverTileState extends ConsumerState<_DiscoverTile> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    await runOrganisationAction(
      context,
      () => ref.read(organisationRepositoryProvider).requestJoin(widget.organisation.id),
      success: 'Beitritt angefragt. Ein Admin der Organisation muss deine Anfrage freigeben.',
      failure: 'Anfrage fehlgeschlagen',
      onSuccess: () => refreshOrganisations(ref, discover: true),
    );
    if (mounted) setState(() => _joining = false);
  }

  @override
  Widget build(BuildContext context) {
    final organisation = widget.organisation;
    final theme = Theme.of(context);
    final members = organisation.memberCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.apartment, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(organisation.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    '$members ${members == 1 ? 'Mitglied' : 'Mitglieder'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  if (organisation.description case final description? when description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            switch (organisation.membershipStatus) {
              OrgMemberStatus.active => const StatusChip(label: 'Mitglied', color: Colors.green),
              OrgMemberStatus.pending => const StatusChip(label: 'Anfrage ausstehend', color: Colors.orange),
              null => FilledButton(
                onPressed: _joining ? null : _join,
                child: _joining
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Beitritt anfragen'),
              ),
            },
          ],
        ),
      ),
    );
  }
}
