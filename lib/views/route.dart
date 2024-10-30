import 'package:coffeeapp/views/screens/admin/curd_screen.dart';
import 'package:coffeeapp/views/screens/signin_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const CURDScreen(
        id: null,
        username: null,
        role: null,
      ),
    ),
  ],
);
