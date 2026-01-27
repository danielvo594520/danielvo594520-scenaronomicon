import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/app_shell.dart';
import '../screens/placeholder_screen.dart';
import '../screens/scenario/scenario_detail_screen.dart';
import '../screens/scenario/scenario_form_screen.dart';
import '../screens/scenario/scenario_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/system_management_screen.dart';
import '../screens/settings/tag_management_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/scenarios',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: シナリオ
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scenarios',
              builder: (context, state) => const ScenarioListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => const ScenarioFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => ScenarioDetailScreen(
                    id: int.parse(state.pathParameters['id']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => ScenarioFormScreen(
                        scenarioId:
                            int.parse(state.pathParameters['id']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Tab 1: プレイ記録（プレースホルダー）
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sessions',
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'プレイ記録'),
            ),
          ],
        ),
        // Tab 2: プレイヤー（プレースホルダー）
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/players',
              builder: (context, state) =>
                  const PlaceholderScreen(title: 'プレイヤー'),
            ),
          ],
        ),
        // Tab 3: 設定
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'systems',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const SystemManagementScreen(),
                ),
                GoRoute(
                  path: 'tags',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) =>
                      const TagManagementScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
