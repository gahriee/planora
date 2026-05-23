import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main_scaffold.dart';
import '../views/auth/auth_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/calendar/calendar_screen.dart';
import '../views/tasks/tasks_screen.dart';
import '../views/tasks/task_detail_screen.dart';
import '../views/profile/profile_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(authProvider, (previous, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      if (authState is AsyncLoading) return null;
      
      final user = authState.value;
      final isAuth = user != null;
      final isAnonymous = user?.email.isEmpty ?? false;
      final isGoingToAuth = state.matchedLocation == '/auth';

      if (!isAuth && !isGoingToAuth) {
        return '/auth';
      }
      if (isAuth && !isAnonymous && isGoingToAuth) {
        return '/';
      }
      return null;
    },
    routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainScaffold(shell: shell),
      branches: [
        // Tab 1 — Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Tab 2 — Calendar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        // Tab 3 — Tasks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksScreen(),
              routes: [
                GoRoute(
                  path: ':taskId',
                  builder: (_, state) => TaskDetailScreen(
                    taskId: state.pathParameters['taskId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
});
