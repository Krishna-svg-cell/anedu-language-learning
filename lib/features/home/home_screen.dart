import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/local_db.dart';
import '../../core/theme/app_theme.dart';
import '../../models/lesson.dart';
import '../../core/widgets/animated_pressable.dart';
import '../../core/widgets/mittu_widget.dart';
import '../../core/services/audio_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Offset _fabOffset = const Offset(0, 0);
  bool _isFabPositionInitialized = false;

  String _getTimeBasedGreeting(String userName) {
    final name = userName.isEmpty ? 'Friend' : userName;
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning, $name! ☀️\nReady for today\'s Kannada mission?';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $name! 🌤️\nLet\'s make progress!';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening, $name! 🌆\nKeep your streak alive!';
    } else {
      return 'Welcome back, $name! 🌙\nStreak active - keep it going!';
    }
  }

  String _getRealLifeGoal(Lesson lesson) {
    if (lesson.id == 'day_1' || lesson.id.contains('basics')) {
      return 'Introduce yourself and greet locals.';
    } else if (lesson.id == 'day_2' || lesson.id.contains('greetings')) {
      return 'Start conversations and introduce friends.';
    } else if (lesson.id == 'day_3' || lesson.id.contains('travel')) {
      return 'Buy tickets and ask for directions.';
    } else if (lesson.id == 'day_4' || lesson.id.contains('restaurant')) {
      return 'Order food and pay at a local Darshini.';
    } else if (lesson.id == 'day_5' || lesson.id.contains('workplace')) {
      return 'Talk with office colleagues and make plans.';
    }
    return 'Master everyday conversations in Kannada.';
  }

  String _getDailyMotivation(int streak) {
    if (streak == 0) return "Let's learn your first Kannada sentence! Banni!";
    if (streak == 1) return "One day down! Let's keep this momentum active.";
    if (streak < 7) return "Look how far you've come already! Mittu is proud of you!";
    return "One week ago Kannada felt new. Look how far you've come! Proud of you explorer.";
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider);
    final lessons = ref.watch(lessonsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isFabPositionInitialized) {
      final size = MediaQuery.of(context).size;
      _fabOffset = Offset(size.width - 76.0, size.height - 200.0);
      _isFabPositionInitialized = true;
    }

    // Find the first incomplete lesson in the sorted curriculum list
    final nextLesson = lessons.firstWhere(
      (l) => !l.isCompleted,
      orElse: () => lessons.first,
    );

    final bool hasCompletedToday = LocalDb.hasCompletedLessonToday();
    final bool isNextLessonLocked = !nextLesson.isUnlocked || (nextLesson.isCompleted == false && hasCompletedToday);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // 1. Top Immersive Header with Vidhana Soudha image
            Stack(
              children: [
                // Vidhana Soudha background image
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Image.asset(
                    'assets/images/situations/vidhana_soudha.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // Soft gradient overlay to ensure text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Header Overlay elements: ANEDU, Streak, and XP
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ANEDU Brand Title (transparent white look with high-contrast shadow)
                      Text(
                        'ANEDU',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      // Transparent Badge stats with glassmorphic backing
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Streak badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text('🔥', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${progress.streakDays}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              // XP badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text('⭐', style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${progress.xp} XP',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. Today's Mission Panel
            Container(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TODAY'S MISSION",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0EA5E9), // Sky Blue
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${nextLesson.xpReward} XP',
                          style: const TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Day ${lessons.indexOf(nextLesson) + 1}',
                          style: const TextStyle(
                            color: Color(0xFF0284C7),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _getRealLifeGoal(nextLesson),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scenario: ${nextLesson.title}',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Edge-to-edge Photo under the Today's Mission text
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                child: Image.asset(
                  nextLesson.illustrationPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
                ),
              ),
            ),

            // Buttons Section
            Container(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Start Mission Button (Sky blue style, no emoji)
                  AnimatedPressable(
                    playSound: false,
                    onTap: () {
                      if (isNextLessonLocked) {
                        AudioService.instance.playLocked();
                        _showLockedBottomSheet(context, isDark);
                      } else {
                        AudioService.instance.playMissionStart();
                        context.push('/lesson/${nextLesson.id}');
                      }
                    },
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9), // Sky Blue background
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA5E9).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'Start Mission',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF0EA5E9),
                              size: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
              
              
              // Thin elegant divider separating the daily mission from the metrics dashboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? Colors.white10 : Colors.grey[200],
                ),
              ),

              // Speaking Confidence Tracker Card
              Container(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "SPEAKING CONFIDENCE OUTCOME",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            progress.cefrLevel,
                            style: const TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Before ANEDU',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${progress.initialConfidence}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF10B981), size: 28),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Real-World Score',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${((progress.survivalOutcomeIntroduce + progress.survivalOutcomeOrder + progress.survivalOutcomeTravel + progress.survivalOutcomeNegotiate + progress.survivalOutcomeProblem) / 5.0).round()}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ((progress.survivalOutcomeIntroduce + progress.survivalOutcomeOrder + progress.survivalOutcomeTravel + progress.survivalOutcomeNegotiate + progress.survivalOutcomeProblem) / 5.0) / 100.0,
                        backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        color: const Color(0xFF10B981),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildOutcomeBar('Introduce Yourself', progress.survivalOutcomeIntroduce.round(), Colors.teal, isDark),
                    _buildOutcomeBar('Order Food', progress.survivalOutcomeOrder.round(), Colors.orange, isDark),
                    _buildOutcomeBar('Ask Directions', progress.survivalOutcomeTravel.round(), Colors.blue, isDark),
                    _buildOutcomeBar('Negotiate Auto/Kirana', progress.survivalOutcomeNegotiate.round(), Colors.purple, isDark),
                    _buildOutcomeBar('Solve Daily Problems', progress.survivalOutcomeProblem.round(), Colors.red, isDark),
                    const SizedBox(height: 12),
                    Text(
                      'Goal: ${progress.motivation} - Customized for ${progress.role} from ${progress.nativeLanguage}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
                  ],
                ),
              ),
          if (_isFabPositionInitialized)
            Positioned(
              left: _fabOffset.dx,
              top: _fabOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _fabOffset += details.delta;
                    final size = MediaQuery.of(context).size;
                    final double minX = 16.0;
                    final double maxX = size.width - 76.0;
                    final double minY = 80.0;
                    final double maxY = size.height - 180.0;
                    _fabOffset = Offset(
                      _fabOffset.dx.clamp(minX, maxX),
                      _fabOffset.dy.clamp(minY, maxY),
                    );
                  });
                },
                child: AnimatedPressable(
                  playSound: false,
                  onTap: () {
                    AudioService.instance.playUnlocked();
                    context.push('/ai-tutor');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOutcomeBar(String label, int percentage, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '$percentage%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showLockedBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  '🔒 Daily Limit Reached',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.secondaryOrange,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You have completed today's learning mission! To build long-term retention, ANEDU limits learning to one new mission per day.\n\nYour next adventure will unlock automatically at 12:00 AM (local time). In the meantime, you can replay completed missions on the Journey tab to practice!",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AnimatedPressable(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Got It!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
