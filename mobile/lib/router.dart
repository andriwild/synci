import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/analytics/analytics.dart';
import 'features/account/account_screen.dart';
import 'features/account/info_screens.dart';
import 'features/onboarding/onboarding_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/organisation/discover_screen.dart';
import 'features/organisation/members_screen.dart';
import 'features/organisation/organisations_screen.dart';
import 'features/sport/sport_detail_screen.dart';
import 'features/sport/sport_tree_screen.dart';
import 'features/start/start_screen.dart';
import 'features/sync_config/abos_screen.dart';

/// go_router 18 looks for material_ui's MaterialApp, not Flutter's, and would otherwise build every page
/// without a transition, so no page slid in, iOS had no swipe back and no hero could fly.
Page<void> _page(GoRouterState state, Widget child) =>
    MaterialPage<void>(key: state.pageKey, name: state.name ?? state.path, child: child);

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    // Read once: finishing the intro navigates by itself
    initialLocation: ref.read(onboardingSeenProvider) ? '/sport' : '/willkommen',
    routes: [
      GoRoute(path: '/willkommen', pageBuilder: (_, state) => _page(state, const OnboardingScreen())),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            // For the same reason, the branch navigators get no HeroController; this one lets the sport icons fly
            observers: [MaterialApp.createMaterialHeroController()],
            routes: [
              GoRoute(
                path: '/sport',
                pageBuilder: (_, state) => _page(state, const StartScreen()),
                routes: [
                  GoRoute(
                    path: 'sportart/:rootId',
                    pageBuilder: (_, state) => _page(state, SportTreeScreen(rootId: state.pathParameters['rootId']!)),
                    routes: [
                      GoRoute(
                        path: ':sportId',
                        pageBuilder: (_, state) =>
                            _page(state, SportDetailScreen(sportId: state.pathParameters['sportId']!)),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':sportId',
                    pageBuilder: (_, state) =>
                        _page(state, SportDetailScreen(sportId: state.pathParameters['sportId']!)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/abos', pageBuilder: (_, state) => _page(state, const AbosScreen()))],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/organisationen',
                pageBuilder: (_, state) => _page(state, const OrganisationsScreen()),
                routes: [
                  GoRoute(
                    path: 'entdecken',
                    pageBuilder: (_, state) => _page(state, const DiscoverOrganisationsScreen()),
                  ),
                  GoRoute(
                    path: ':organisationId/mitglieder',
                    pageBuilder: (_, state) =>
                        _page(state, MembersScreen(organisationId: state.pathParameters['organisationId']!)),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/konto',
                pageBuilder: (_, state) => _page(state, const AccountScreen()),
                routes: [
                  GoRoute(path: 'faq', pageBuilder: (_, state) => _page(state, const FaqScreen())),
                  GoRoute(path: 'impressum', pageBuilder: (_, state) => _page(state, const ImpressumScreen())),
                  GoRoute(
                    path: 'einfuehrung',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (_, state) => _page(state, const OnboardingScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  final analytics = ref.read(analyticsProvider);
  String? lastPath;
  void trackScreen() {
    final path = router.routerDelegate.currentConfiguration.uri.path
        .replaceAllMapped(RegExp(r'^/sport/sportart/[^/]+/[^/]+'), (_) => '/sport/detail')
        .replaceAllMapped(RegExp(r'^/sport/sportart/[^/]+$'), (_) => '/sport/sportart')
        .replaceAllMapped(RegExp(r'^/sport/(?!sportart(?:/|$))[^/]+'), (_) => '/sport/detail')
        .replaceAllMapped(RegExp(r'^/organisationen/(?!entdecken)[^/]+'), (_) => '/organisationen/detail');
    if (path == lastPath) return;
    lastPath = path;
    analytics.screen(path);
  }

  router.routerDelegate.addListener(trackScreen);
  ref.onDispose(() {
    router.routerDelegate.removeListener(trackScreen);
    router.dispose();
  });
  return router;
});

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(body: navigationShell, bottomNavigationBar: _tabs());

  Widget _tabs() => NavigationBar(
    selectedIndex: navigationShell.currentIndex,
    // Tapping the active tab again returns to its root
    onDestinationSelected: (index) =>
        navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Start'),
      NavigationDestination(
        icon: Icon(Icons.event_note_outlined),
        selectedIcon: Icon(Icons.event_note),
        label: 'Meine Abos',
      ),
      NavigationDestination(
        icon: Icon(Icons.apartment_outlined),
        selectedIcon: Icon(Icons.apartment),
        label: 'Organisationen',
      ),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Konto'),
    ],
  );
}
