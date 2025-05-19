import 'package:go_router/go_router.dart';
import '../screens/homeScreen.dart';
import '../screens/loginScreen.dart';
import '../screens/notFoundScreen.dart';
import '../screens/signupScreen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/home'),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}