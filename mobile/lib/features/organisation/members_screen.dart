import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
import '../account/login_prompt.dart';
import 'organisation.dart';
import 'organisation_actions.dart';
import 'organisation_providers.dart';
import 'organisation_repository.dart';
import 'organisations_screen.dart';

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key, required this.organisationId});

  final String organisationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final organisation = ref.watch(organisationDetailProvider(organisationId));
    final members = ref.watch(organisationMembersProvider(organisationId));

    void retry() => refreshOrganisations(ref, mine: false, members: organisationId);

    return Scaffold(
      appBar: AppBar(title: Text(organisation.value?.name ?? 'Mitglieder')),
      body: switch ((user.value, organisation, members)) {
        (null, _, _) when !user.isLoading => const LoginRequiredView(
          message: 'Melde dich an, um die Mitglieder zu verwalten',
        ),
        (_, AsyncError(:final error), _) =>
          error is ApiException && error.statusCode == 'FORBIDDEN'
              ? const EmptyView(
                  icon: Icons.lock_outline,
                  message: 'Kein Zugriff\nNur aktive Mitglieder sehen die Mitgliederliste.',
                )
              : ErrorView(error: error, onRetry: retry),
        (_, _, AsyncError(:final error)) => ErrorView(error: error, onRetry: retry),
        (_, AsyncData(value: final organisation), AsyncData(value: final members)) => _MemberList(
          organisation: organisation,
          members: members,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _MemberList extends ConsumerStatefulWidget {
  const _MemberList({required this.organisation, required this.members});

  final MyOrganisation organisation;
  final List<OrganisationMember> members;

  @override
  ConsumerState<_MemberList> createState() => _MemberListState();
}

class _MemberListState extends ConsumerState<_MemberList> {
  String? _busyMember;

  OrganisationRepository get _repository => ref.read(organisationRepositoryProvider);
  String get _id => widget.organisation.id;

  Future<void> _run(
    String memberId,
    Future<void> Function() action, {
    required String success,
    bool discover = false,
  }) async {
    setState(() => _busyMember = memberId);
    await runOrganisationAction(
      context,
      action,
      success: success,
      failure: 'Aktion fehlgeschlagen',
      onSuccess: () => refreshOrganisations(ref, members: _id, discover: discover),
    );
    if (mounted) setState(() => _busyMember = null);
  }

  Future<void> _remove(OrganisationMember member) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '${member.displayName} entfernen?',
      message: '${member.displayName} sieht danach die Events dieser Organisation nicht mehr.',
      confirmLabel: 'Entfernen',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run(member.id, () => _repository.removeMember(_id, member.id), success: 'Mitglied entfernt', discover: true);
  }

  Future<void> _leave() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '"${widget.organisation.name}" verlassen?',
      message: 'Du siehst danach die Events dieser Organisation nicht mehr.',
      confirmLabel: 'Verlassen',
    );
    if (!confirmed || !mounted) return;
    final left = await runOrganisationAction(
      context,
      () => _repository.leave(_id),
      success: 'Organisation verlassen',
      failure: 'Aktion fehlgeschlagen',
      onSuccess: () => refreshOrganisations(ref, discover: true, syncConfigs: true, events: true),
    );
    if (left && mounted) context.go('/organisationen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = widget.organisation.isAdmin;
    final pending = widget.members.where((m) => m.status == OrgMemberStatus.pending).toList();
    final active = widget.members.where((m) => m.status == OrgMemberStatus.active).toList();
    final adminCount = active.where((m) => m.role == OrgRole.admin).length;
    final lastAdmin = isAdmin && adminCount <= 1;

    Widget sectionTitle(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );

    return RefreshIndicator(
      onRefresh: () async => refreshOrganisations(ref, mine: false, members: _id),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(label: widget.organisation.role.label, color: theme.colorScheme.primary),
            ),
          ),
          if (isAdmin && pending.isNotEmpty) ...[
            sectionTitle('Offene Anfragen (${pending.length})'),
            for (final member in pending)
              _MemberTile(
                member: member,
                busy: _busyMember == member.id,
                actions: [
                  IconButton(
                    tooltip: 'Ablehnen',
                    icon: const Icon(Icons.close),
                    onPressed: () =>
                        _run(member.id, () => _repository.removeMember(_id, member.id), success: 'Anfrage abgelehnt'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _run(
                      member.id,
                      () => _repository.approveMember(_id, member.id),
                      success: 'Mitglied freigegeben',
                      discover: true,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Freigeben'),
                  ),
                ],
              ),
          ],
          sectionTitle('Mitglieder (${active.length})'),
          for (final member in active)
            _MemberTile(
              member: member,
              busy: _busyMember == member.id,
              actions: isAdmin
                  ? [
                      _RoleMenu(
                        member: member,
                        locked: member.role == OrgRole.admin && adminCount <= 1,
                        onChanged: (role) => _run(
                          member.id,
                          () => _repository.updateMemberRole(_id, member.id, role),
                          success: 'Rolle geändert',
                        ),
                      ),
                      if (!member.isMe)
                        IconButton(
                          tooltip: member.role == OrgRole.admin && adminCount <= 1
                              ? 'Der letzte Admin kann nicht entfernt werden'
                              : 'Entfernen',
                          color: theme.colorScheme.error,
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: member.role == OrgRole.admin && adminCount <= 1 ? null : () => _remove(member),
                        ),
                    ]
                  : [StatusChip(label: member.role.label, color: theme.colorScheme.primary)],
            ),
          const SizedBox(height: 24),
          Tooltip(
            message: lastAdmin ? 'Ernenne zuerst einen weiteren Admin' : '',
            child: OutlinedButton.icon(
              onPressed: lastAdmin ? null : _leave,
              icon: const Icon(Icons.logout),
              label: const Text('Organisation verlassen'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.actions, required this.busy});

  final OrganisationMember member;
  final List<Widget> actions;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final showEmail = member.name != null && member.name!.isNotEmpty && member.email != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.account_circle_outlined, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${member.displayName}${member.isMe ? ' (du)' : ''}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (showEmail) Text(member.email!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            ...actions,
        ],
      ),
    );
  }
}

class _RoleMenu extends StatelessWidget {
  const _RoleMenu({required this.member, required this.locked, required this.onChanged});

  final OrganisationMember member;
  final bool locked;
  final ValueChanged<OrgRole> onChanged;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: locked ? 'Der letzte Admin kann nicht herabgestuft werden' : 'Rolle ändern',
    child: DropdownButton<OrgRole>(
      value: member.role,
      underline: const SizedBox.shrink(),
      onChanged: locked ? null : (role) => role == null || role == member.role ? null : onChanged(role),
      items: [for (final role in OrgRole.values) DropdownMenuItem(value: role, child: Text(role.label))],
    ),
  );
}
