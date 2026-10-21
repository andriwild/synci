import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/auth/auth_service.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/synci_logo.dart';
import '../../theme.dart';
import '../account/login_prompt.dart';
import '../app_update/update_banner.dart';
import '../organisation/organisation.dart';
import '../organisation/organisation_providers.dart';
import '../organisation/organisations_screen.dart';
import '../sport/sport.dart';
import '../sport/sport_icons.dart';
import '../sport/sport_providers.dart';
import '../sync_config/active_abo_bar.dart';

/// Opens a sport or organisation from the start screen: its leagues or groups if it has some, otherwise its events.
void openRootSport(BuildContext context, WidgetRef ref, Sport sport) {
  if (!sport.isOrganisation) {
    ref.read(analyticsProvider).event('sport-select', {'sport': sport.label, 'level': 0});
  }
  context.go(sport.hasSubSports ? '/sport/sportart/${sport.id}' : '/sport/${sport.id}');
}

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  final _searchController = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) => setState(() => _query = value.trim());

  @override
  Widget build(BuildContext context) {
    final sports = ref.watch(sportsProvider);
    final organisations = ref.watch(myOrganisationsProvider);
    final user = ref.watch(authControllerProvider).value;
    final activeOrganisations = [
      for (final organisation in organisations.value ?? const <MyOrganisation>[])
        if (!organisation.isPending) organisation,
    ];
    final organisationSection = _OrganisationSection(
      loggedIn: user != null,
      organisations: organisations,
      active: activeOrganisations,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 28, semanticLabel: 'Synci'),
      ),
      bottomNavigationBar: const ActiveAboBar(),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([ref.refresh(sportsProvider.future), ref.refresh(myOrganisationsProvider.future)]),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList.list(
                children: [
                  const UpdateBanner(padding: EdgeInsets.only(bottom: 12)),
                  _Greeting(user: user),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: _search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Sportart, Liga oder Organisation suchen',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Suche löschen',
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _search('');
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (_query.isNotEmpty)
              _SearchResults(query: _query)
            else ...[
              // Members see their organisations first, everyone else gets to the sports right away
              if (activeOrganisations.isNotEmpty) organisationSection,
              const _SectionHeader(
                title: 'Sportarten',
                subtitle: 'Wähle eine Sportart, dann eine Liga oder ein Team, und füge sie deinem Abo hinzu.',
              ),
              sports.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: ErrorView(error: error, onRetry: () => ref.invalidate(sportsProvider)),
                ),
                data: (list) => list.isEmpty
                    ? const SliverToBoxAdapter(
                        child: EmptyView(icon: Icons.search_off, message: 'Keine Sportarten gefunden'),
                      )
                    : _TileGrid(
                        children: [
                          for (final sport in list)
                            _SportTile(sport: sport, onTap: () => openRootSport(context, ref, sport)),
                        ],
                      ),
              ),
              if (activeOrganisations.isEmpty) organisationSection,
            ],
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final AppUser? user;

  String get _title {
    final user = this.user;
    if (user == null) return 'Willkommen bei Synci';
    final name = user.fullName ?? (user.name == user.email ? null : user.name);
    final firstName = name?.trim().split(RegExp(r'\s+')).first;
    return firstName == null || firstName.isEmpty || firstName.contains('@') ? 'Hallo' : 'Hallo $firstName';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(color: SynciColors.container, borderRadius: BorderRadius.circular(20)),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(_title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  'Verpasse nie wieder deine Lieblingsevents: Hol sie dir direkt in deinen Kalender.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const ExcludeSemantics(child: SynciLogo(size: 40)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
            if (subtitle != null)
              Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}

/// Two or more columns of tiles; their height grows with the text size.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final lineScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.list(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisExtent: 80 + 58 * lineScale,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        children: children,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.subtitle, required this.onTap, this.color});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color ?? SynciColors.container,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: theme.colorScheme.primary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle case final subtitle? when subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({required this.sport, required this.onTap});

  final Sport sport;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Tile(
    icon: sportIcon(sport),
    title: sport.label,
    subtitle: sport.hasSubSports
        ? sport.subSports.map((s) => s.label).join(' · ')
        : (sport.isOrganisation ? 'Alle Termine' : null),
    onTap: onTap,
  );
}

class _OrganisationSection extends ConsumerWidget {
  const _OrganisationSection({required this.loggedIn, required this.organisations, required this.active});

  final bool loggedIn;
  final AsyncValue<List<MyOrganisation>> organisations;
  final List<MyOrganisation> active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const description = 'Vereine und Gruppen teilen hier ihre eigenen Termine, z.B. Trainings oder Anlässe.';
    void askLogin() => showLoginPrompt(
      context,
      ref,
      message: 'Melde dich an, um einer Organisation beizutreten oder eine eigene zu erstellen.',
    );
    return SliverMainAxisGroup(
      slivers: [
        _SectionHeader(
          title: active.isEmpty ? 'Organisationen' : 'Meine Organisationen',
          subtitle: active.isEmpty ? description : null,
        ),
        if (organisations.hasError && active.isEmpty)
          SliverToBoxAdapter(
            child: ErrorView(error: organisations.error!, onRetry: () => ref.invalidate(myOrganisationsProvider)),
          )
        else
          _TileGrid(
            children: [
              for (final organisation in active)
                _SportTile(sport: organisation.sport, onTap: () => openRootSport(context, ref, organisation.sport)),
              _Tile(
                icon: Icons.explore_outlined,
                title: 'Entdecken',
                subtitle: 'Finde deinen Verein oder deine Gruppe',
                color: SynciColors.highlight.withValues(alpha: 0.45),
                onTap: loggedIn ? () => context.go('/organisationen/entdecken') : askLogin,
              ),
              _Tile(
                icon: Icons.add,
                title: 'Erstellen',
                subtitle: 'Für deinen Verein, dein Team oder deine Gruppe',
                color: SynciColors.highlight.withValues(alpha: 0.45),
                onTap: loggedIn ? () => showCreateOrganisationDialog(context, ref) : askLogin,
              ),
            ],
          ),
      ],
    );
  }
}

typedef _SearchHit = ({Sport sport, Sport root, List<String> path});

/// Searches the whole tree, organisations included, by label.
List<_SearchHit> _searchTree(List<Sport> roots, String query) {
  final needle = query.toLowerCase();
  final hits = <_SearchHit>[];
  void visit(Sport sport, Sport root, List<String> path) {
    if (sport.label.toLowerCase().contains(needle)) hits.add((sport: sport, root: root, path: path));
    for (final child in sport.subSports) {
      visit(child, root, [...path, sport.label]);
    }
  }

  for (final root in roots) {
    visit(root, root, const []);
  }
  return hits;
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  void _open(BuildContext context, WidgetRef ref, _SearchHit hit) {
    if (hit.sport.id == hit.root.id) return openRootSport(context, ref, hit.root);
    if (!hit.sport.isOrganisation) {
      ref.read(analyticsProvider).event('sport-select', {'sport': hit.sport.label, 'level': hit.path.length});
    }
    context.go('/sport/sportart/${hit.root.id}/${hit.sport.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tree = ref.watch(sportTreeProvider).value ?? const <Sport>[];
    final hits = _searchTree(tree, query);
    if (hits.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyView(icon: Icons.search_off, message: 'Nichts gefunden. Teams findest du in ihrer Liga.'),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
      sliver: SliverList.builder(
        itemCount: hits.length,
        itemBuilder: (context, index) {
          final hit = hits[index];
          return ListTile(
            leading: Icon(sportIcon(hit.root)),
            title: Text(hit.sport.label),
            subtitle: hit.path.isEmpty ? null : Text(hit.path.join(' › ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, ref, hit),
          );
        },
      ),
    );
  }
}
