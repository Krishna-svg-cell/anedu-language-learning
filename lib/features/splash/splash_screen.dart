import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/local_db.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mittu_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _startTimer();
  }

  void _startTimer() {
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final onboardingDone = LocalDb.isOnboardingCompleted;
        if (onboardingDone) {
          context.go(
            '/home',
          ); // Skip onboarding and login, direct to home dashboard
        } else {
          context.go('/auth'); // Route to authentication page first
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppTheme.darkBg, const Color(0xFF1E1E38)]
                : [const Color(0xFFEBF3FE), Colors.white],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated Waving Mittu
              const Center(
                child: MittuWidget(
                  mood: MittuMood.waving,
                  size: 200,
                  animate: true,
                ),
              ),
              const SizedBox(height: 24),
              // App Name Text
              Text(
                'ANEDU',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              // Tagline
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Learn Kannada. Live Karnataka.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              // Premium Progress Indicator
              const SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  backgroundColor: Color(0xFFE2E8F0),
                  color: AppTheme.primaryBlue,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
