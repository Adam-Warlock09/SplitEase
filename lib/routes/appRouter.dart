import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:split_ease/providers/sessionProvider.dart';
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
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
    redirect: (BuildContext context, GoRouterState state) {

      final session = Provider.of<SessionProvider>(context, listen: false);
      final loggedIn = session.isLoggedIn;
      final goingTo = state.matchedLocation;

      if (goingTo == "/login" && loggedIn) {
        return "/dashboard";
      }

      if (goingTo == "/dashboard" && !loggedIn) {
        return "/home";
      }

      return null;

    }
  );
}