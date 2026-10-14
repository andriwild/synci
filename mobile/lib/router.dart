import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/analytics/analytics.dart';
import 'features/account/account_screen.dart';
import 'features/account/info_screens.dart';
import 'features/sport/sport_detail_screen.dart';
import 'features/sport/sport_tree_screen.dart';
import 'features/sync_config/abos_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/sport',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sport',
                builder: (_, _) => const SportTreeScreen(),
                routes: [
                  GoRoute(
                    path: ':sportId',
                    builder: (_, state) => SportDetailScreen(sportId: state.pathParameters['sportId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/abos', builder: (_, _) => const AbosScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/konto',
                builder: (_, _) => const AccountScreen(),
                routes: [
                  GoRoute(path: 'faq', builder: (_, _) => const FaqScreen()),
                  GoRoute(path: 'impressum', builder: (_, _) => const ImpressumScreen()),
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
    final path = router.routerDelegate.currentConfiguration.uri.path.replaceAllMapped(
      RegExp(r'^/sport/[^/]+'),
      (_) => '/sport/detail',
    );
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
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      // Tapping the active tab again returns to its root
      onDestinationSelected: (index) =>
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.sports_soccer_outlined),
          selectedIcon: Icon(Icons.sports_soccer),
          label: 'Sportarten',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Meine Abos',
        ),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Konto'),
      ],
    ),
  );
}
