import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/providers/sessionProvider.dart';
import 'package:split_ease/screens/createGroupScreen.dart';
import 'package:split_ease/screens/groupScreen.dart';
import 'package:split_ease/screens/groupsScreen.dart';
import '../screens/homeScreen.dart';
import '../screens/loginScreen.dart';
import '../screens/notFoundScreen.dart';
import '../screens/signupScreen.dart';
import '../screens/dashboardScreen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/home'),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardPage()),
      GoRoute(path: '/groups', builder: (context, state) => const GroupsPage()),
      GoRoute(path: '/groups/create', builder: (context, state) => const CreateGroupPage()),
      GoRoute(path: '/group/:id', builder: (context, state) {
        final groupID = state.pathParameters['id']!;
        return GroupDetailsPage(groupID: groupID);
      }),
      GoRoute(path: '/group/:id/members', builder: (context, state) {
        final groupID = state.pathParameters['id']!;
        return GroupDetailsPage(groupID: groupID);
      }),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
    redirect: (BuildContext context, GoRouterState state) {

      final session = Provider.of<SessionProvider>(context, listen: false);
      final loggedIn = session.isLoggedIn;
      final goingTo = state.matchedLocation;

      if (goingTo == "/login" && loggedIn) {
        return "/dashboard";
      }

      final protectedPrefixes = ['/group/'];
      final protectedRoutes = ['/dashboard', '/groups'];

      if (!loggedIn && (protectedPrefixes.any((prefix) => goingTo.startsWith(prefix)) || protectedRoutes.contains(goingTo))) {
        return '/home';
      }

      return null;

    }
  );
}