import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/homeScreen.dart';
import '../screens/notFoundScreen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/home'),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}