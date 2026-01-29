import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/app_shell.dart';
import '../screens/character/character_detail_screen.dart';
import '../screens/character/character_form_screen.dart';
import '../screens/character/character_list_screen.dart';
import '../screens/play_session/play_session_form_screen.dart';
import '../screens/play_session/play_session_list_screen.dart';
import '../screens/player/player_detail_screen.dart';
import '../screens/player/player_form_screen.dart';
import '../screens/player/player_list_screen.dart';
import '../screens/scenario/scenario_detail_screen.dart';
import '../screens/scenario/scenario_form_screen.dart';
import '../screens/scenario/scenario_list_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/system_management_screen.dart';
import '../screens/settings/tag_management_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// フェードトランジション付きのページを生成
CustomTransitionPage<void> _fadeTransitionPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

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
                  pageBuilder: (context, state) => _fadeTransitionPage(
                    state: state,
                    child: const ScenarioFormScreen(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeTransitionPage(
                    state: state,
                    child: ScenarioDetailScreen(
                      id: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => _fadeTransitionPage(
                        state: state,
                        child: ScenarioFormScreen(
                          scenarioId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // Tab 1: プレイ記録
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sessions',
              builder: (context, state) =>
                  const PlaySessionListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    final scenarioIdStr =
                        state.uri.queryParameters['scenarioId'];
                    return _fadeTransitionPage(
                      state: state,
                      child: PlaySessionFormScreen(
                        preselectedScenarioId: scenarioIdStr != null
                            ? int.tryParse(scenarioIdStr)
                            : null,
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: ':id/edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeTransitionPage(
                    state: state,
                    child: PlaySessionFormScreen(
                      sessionId:
                          int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Tab 2: プレイヤー
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/players',
              builder: (context, state) => const PlayerListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeTransitionPage(
                    state: state,
                    child: const PlayerFormScreen(),
                  ),
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeTransitionPage(
                    state: state,
                    child: PlayerDetailScreen(
                      id: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => _fadeTransitionPage(
                        state: state,
                        child: PlayerFormScreen(
                          playerId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ),
                    // キャラクター関連ルート
                    GoRoute(
                      path: 'characters',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) => _fadeTransitionPage(
                        state: state,
                        child: CharacterListScreen(
                          playerId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                      routes: [
                        GoRoute(
                          path: 'new',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) =>
                              _fadeTransitionPage(
                            state: state,
                            child: CharacterFormScreen(
                              playerId:
                                  int.parse(state.pathParameters['id']!),
                            ),
                          ),
                        ),
                        GoRoute(
                          path: ':characterId',
                          parentNavigatorKey: _rootNavigatorKey,
                          pageBuilder: (context, state) =>
                              _fadeTransitionPage(
                            state: state,
                            child: CharacterDetailScreen(
                              playerId:
                                  int.parse(state.pathParameters['id']!),
                              characterId: int.parse(
                                  state.pathParameters['characterId']!),
                            ),
                          ),
                          routes: [
                            GoRoute(
                              path: 'edit',
                              parentNavigatorKey: _rootNavigatorKey,
                              pageBuilder: (context, state) =>
                                  _fadeTransitionPage(
                                state: state,
                                child: CharacterFormScreen(
                                  playerId: int.parse(
                                      state.pathParameters['id']!),
                                  characterId: int.parse(
                                      state.pathParameters['characterId']!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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
                  pageBuilder: (context, state) => _fadeTransitionPage(
                    state: state,
                    child: const SystemManagementScreen(),
                  ),
                ),
                GoRoute(
                  path: 'tags',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) => _fadeTransitionPage(
                    state: state,
                    child: const TagManagementScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
