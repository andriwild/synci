import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/press_scale.dart';
import '../../theme.dart';
import '../account/login_prompt.dart';
import '../app_update/update_banner.dart';
import '../organisation/organisation.dart';
import '../organisation/organisation_providers.dart';
import '../organisation/organisations_screen.dart';
import '../sport/sport.dart';
import '../sport/sport_icons.dart';
import '../sport/sport_providers.dart';

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
  final _searchFocus = FocusNode();
  final _scroll = ScrollController();
  var _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _search(String value) => setState(() => _query = value.trim());

  /// The search icon of the collapsed header brings the search field back.
  Future<void> _openSearch() async {
    await _scroll.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final sports = ref.watch(sportsProvider);
    final organisations = ref.watch(myOrganisationsProvider);
    // Loaded before a tile opens its leagues, so their title is there for the icon to fly into
    ref.watch(sportTreeProvider);
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

    final searchField = TextField(
      controller: _searchController,
      focusNode: _searchFocus,
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
    );

    return Scaffold(
      body: RefreshIndicator(
        edgeOffset: MediaQuery.paddingOf(context).top + kToolbarHeight,
        onRefresh: () => Future.wait([ref.refresh(sportsProvider.future), ref.refresh(myOrganisationsProvider.future)]),
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 2,
              shadowColor: Colors.black26,
              expandedHeight: _StartHeader.expandedHeight,
              flexibleSpace: _StartHeader(searchField: searchField, onSearch: _openSearch),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              sliver: SliverToBoxAdapter(child: UpdateBanner(padding: EdgeInsets.only(bottom: 8))),
            ),
            if (_query.isNotEmpty)
              _SearchResults(query: _query)
            else ...[
              organisationSection,
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
            ],
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

/// Big logo above the search field; scrolling down shrinks the logo into the toolbar and turns the
/// field into a search icon there.
class _StartHeader extends StatelessWidget {
  const _StartHeader({required this.searchField, required this.onSearch});

  static const expandedHeight = 150.0;
  static const _logo = (small: 28.0, big: 52.0);

  final Widget searchField;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return LayoutBuilder(
      builder: (context, constraints) {
        // 1 while fully expanded, 0 once collapsed into the toolbar
        final t = ((constraints.maxHeight - top - kToolbarHeight) / (expandedHeight - kToolbarHeight)).clamp(0.0, 1.0);
        final logoHeight = lerpDouble(_logo.small, _logo.big, t)!;
        final fieldOpacity = ((t - 0.4) / 0.6).clamp(0.0, 1.0);
        final iconOpacity = (1 - t / 0.4).clamp(0.0, 1.0);
        return Padding(
          padding: EdgeInsets.only(top: top),
          child: Stack(
            children: [
              Positioned(
                top: lerpDouble((kToolbarHeight - _logo.small) / 2, 12, t),
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset('assets/images/logo.png', height: logoHeight, semanticLabel: 'Synci'),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: IgnorePointer(
                  ignoring: fieldOpacity < 0.5,
                  child: Opacity(opacity: fieldOpacity, child: searchField),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IgnorePointer(
                  ignoring: iconOpacity < 0.5,
                  child: Opacity(
                    opacity: iconOpacity,
                    child: IconButton(tooltip: 'Suchen', icon: const Icon(Icons.search), onPressed: onSearch),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  /// Grows with the text size.
  static double tileHeight(BuildContext context) => 80 + 58 * MediaQuery.textScalerOf(context).scale(14) / 14;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.list(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisExtent: tileHeight(context),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        children: children,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.subtitle, required this.onTap, this.color, this.sport});

  final IconData icon;

  /// Shows its avatar instead of [icon], which then flies into the next page.
  final Sport? sport;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = Material(
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
              if (sport case final sport?)
                SportAvatar(sport: sport)
              else
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
    return PressScale(child: tile);
  }
}

class _SportTile extends StatelessWidget {
  const _SportTile({required this.sport, required this.onTap});

  final Sport sport;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Tile(
    icon: sportIcon(sport),
    sport: sport,
    title: sport.label,
    subtitle: sport.hasSubSports
        ? sport.subSports.map((s) => s.label).join(' · ')
        : sport.isOrganisation
        ? 'Alle Termine'
        : sport.isTopEvents
        ? 'Spiele zwischen zwei Teams'
        : null,
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
          _TileRow(
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

/// One row of tiles that scrolls sideways, so it stays short however many there are.
class _TileRow extends StatelessWidget {
  const _TileRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: SizedBox(
      height: _TileGrid.tileHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) => SizedBox(width: 164, child: children[index]),
      ),
    ),
  );
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
