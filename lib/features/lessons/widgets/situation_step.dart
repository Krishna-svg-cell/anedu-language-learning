import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../models/lesson.dart';

import '../../../../core/widgets/dynamic_scene_illustration.dart';

class SituationStep extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onCompleted;
  final bool showIllustrationOnly; // Retained for backward compatibility
  final bool showTextOnly; // Retained for backward compatibility

  const SituationStep({
    super.key,
    required this.lesson,
    required this.onCompleted,
    this.showIllustrationOnly = false,
    this.showTextOnly = false,
  });

  @override
  State<SituationStep> createState() => _SituationStepState();
}

class _SituationStepState extends State<SituationStep> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    
    // Slow, cinematic zoom animation (Ken Burns effect)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Slide up animation for the scenario card
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.12, curve: Curves.easeOutCubic),
      ),
    );

    // Run the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getIllustrationPath(LessonCategory category) {
    switch (category) {
      case LessonCategory.basics:
        return 'assets/images/situations/basics_1.webp';
      case LessonCategory.greetings:
      case LessonCategory.introductions:
      case LessonCategory.fluentConversation:
        return 'assets/images/situations/greetings_1.webp';
      case LessonCategory.travel:
        return 'assets/images/situations/travel_1.webp';
      case LessonCategory.restaurant:
        return 'assets/images/situations/restaurant_1.webp';
      case LessonCategory.shopping:
        return 'assets/images/situations/shopping_1.webp';
      case LessonCategory.workplace:
      case LessonCategory.college:
        return 'assets/images/situations/workplace_1.webp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String imagePath = widget.lesson.illustrationPath;
    final screenHeight = MediaQuery.of(context).size.height;
    final double imageHeight = screenHeight > 800 ? 320.0 : 240.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Immersive Hero Illustration with Cinematic Zoom and Dynamic Filters
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: child,
            );
          },
          child: DynamicSceneIllustration(
            imagePath: imagePath,
            stepIndex: 1, // Scenario is Scene 1 of the adventure
            height: imageHeight,
          ),
        ),
        const SizedBox(height: 40),

        // 2. Scenario Description Details Card with Entry Slide
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0.0, _slideAnimation.value),
              child: Opacity(
                opacity: ((30.0 - _slideAnimation.value) / 30.0).clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: AppTheme.glassCardDecoration(
              context: context,
              radius: 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'MISSION SCENARIO',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Lesson Title
                Text(
                  widget.lesson.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                // Immersive Situation Description
                Text(
                  widget.lesson.situationDescription,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
