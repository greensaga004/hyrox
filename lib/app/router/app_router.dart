// app/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:hyrox/features/session/presentation/screens/session_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <GoRoute>[
    GoRoute(path: '/', builder: (context, state) => const SessionScreen()),
  ],
);
