import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/app_controller.dart';
import '../localization/strings.dart';
import '../../features/auth/presentation/auth_pages.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/planning/presentation/planning_page.dart';
import '../../features/study/presentation/study_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/calendar/presentation/calendar_page.dart';
import '../../features/profile/presentation/profile_pages.dart';
import '../../features/notifications/presentation/notifications_page.dart';
import '../../features/flashcards/presentation/flashcard_pages.dart';
import '../../features/tools/presentation/tools_page.dart';
import '../../features/roadmap/presentation/roadmap_page.dart';
import '../../features/reference/presentation/reference_pages.dart';
class RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefresh();
  ref.listen(appProvider.select((s) => (s.onboarded, s.signedIn, s.user.name.isEmpty)),
    (_, __) => refresh.refresh());
  final router = GoRouter(initialLocation: '/home', refreshListenable: refresh,
    redirect: (context, route) {
      final data = ref.read(appProvider), path = route.uri.path;
      if (!data.onboarded) return path == '/welcome' ? null : '/welcome';
      if (!data.signedIn) return ['/login', '/verify'].contains(path) ? null : '/login';
      if (data.user.name.trim().isEmpty) return path == '/profile/edit' ? null : '/profile/edit';
      if (['/welcome', '/login', '/verify'].contains(path)) return '/home';
      return null;
    }, errorBuilder: (context, state) => Scaffold(body: Center(child: FilledButton(
      onPressed: () => context.go('/home'), child: const Text(S.home)))), routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/verify', builder: (_, s) => VerifyPage(phone: s.uri.queryParameters['phone'] ?? '')),
      ShellRoute(builder: (_, state, child) => AppShell(location: state.uri.path, child: child), routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/planning', builder: (_, __) => const PlanningPage()),
        GoRoute(path: '/study', builder: (_, __) => const StudyPage()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsPage()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
      ]),
      GoRoute(path: '/profile/edit', builder: (_, __) => const ProfileEditor()),
      GoRoute(path: '/planning/new', builder: (_, s) => PlanEditor(day: s.uri.queryParameters['day'])),
      GoRoute(path: '/planning/edit/:id', builder: (_, s) => PlanEditor(id: s.pathParameters['id'])),
      GoRoute(path: '/study/finish', builder: (_, __) => const FinishPage()),
      GoRoute(path: '/calendar', builder: (_, __) => const CalendarPage()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
      GoRoute(path: '/flashcards', builder: (_, __) => const FlashcardsPage()),
      GoRoute(path: '/flashcards/new', builder: (_, __) => const CardEditor()),
      GoRoute(path: '/tools', builder: (_, __) => const ToolsPage()),
      GoRoute(path: '/roadmap', builder: (_, __) => const RoadmapPage()),
      GoRoute(path: '/room', builder: (_, __) => const StudyRoomPage()),
      GoRoute(path: '/flash-packs', builder: (_, __) => const FlashPackStorePage()),
      GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardPage()),
      GoRoute(path: '/grade-average', builder: (_, __) => const GradeAveragePage()),
      GoRoute(path: '/percent', builder: (_, __) => const PercentCalculatorPage()),
      GoRoute(path: '/sleep-design', builder: (_, __) => const SleepDesignPage()),
    ]);
  ref.onDispose(() { router.dispose(); refresh.dispose(); });
  return router;
});
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});
  final String location;
  final Widget child;
  static const paths = ['/home', '/planning', '/study', '/reports', '/profile'];
  static const labels = [S.home, S.planning, S.study, S.reports, S.profile];
  static const icons = [Icons.home_outlined, Icons.calendar_view_week_outlined,
    Icons.timelapse_rounded, Icons.bar_chart_rounded, Icons.person_outline_rounded];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = paths.indexOf(location).clamp(0, 4).toInt();
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final timer = ref.watch(appProvider).timer;
    return Scaffold(body: SafeArea(child: Row(children: [
      if (wide) NavigationRail(selectedIndex: index, labelType: NavigationRailLabelType.all,
        onDestinationSelected: (i) => context.go(paths[i]), destinations: [for (var i = 0; i < 5; i++)
          NavigationRailDestination(icon: Icon(icons[i]), label: Text(labels[i]))]),
      Expanded(child: Column(children: [
        if (timer != null && location != '/study') Material(color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(leading: const Icon(Icons.timelapse_rounded), title: Text(timer.topic),
            subtitle: const Text(S.continueStudy), trailing: const Icon(Icons.chevron_left),
            onTap: () => context.go('/study'))),
        Expanded(child: child),
      ])),
    ])), bottomNavigationBar: wide ? null : NavigationBar(selectedIndex: index,
      onDestinationSelected: (i) => context.go(paths[i]), destinations: [for (var i = 0; i < 5; i++)
        NavigationDestination(icon: Icon(icons[i]), label: labels[i])]));
  }
}
