import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/main_shell.dart';
import '../../features/lessons/lesson_screen.dart';
import '../../features/ai_tutor/ai_tutor_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/profile/edit_preferences_screen.dart';
import '../../features/script/aksharamale_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash screen is initial entrypoint
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      // Authentication screen
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      // Onboarding screen
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Main app shell (Home + tabs)
      GoRoute(path: '/home', builder: (context, state) => const MainShell()),
      // Lesson engine screen
      GoRoute(
        path: '/lesson/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'basics_1';
          return LessonScreen(lessonId: id);
        },
      ),
      // AI conversation screen
      GoRoute(
        path: '/ai-tutor',
        builder: (context, state) => const AiTutorScreen(),
      ),
      // App settings screen
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      // Edit preferences screen
      GoRoute(
        path: '/edit-preferences',
        builder: (context, state) => const EditPreferencesScreen(),
      ),
      // Aksharamale script tracing screen
      GoRoute(
        path: '/aksharamale',
        builder: (context, state) => const AksharamaleScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Navigation error: ${state.error}'))),
  );
}
