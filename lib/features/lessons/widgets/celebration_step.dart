import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widgets/mittu_companion_header.dart';
import '../../../../core/widgets/mittu_widget.dart';
import '../../../../models/lesson.dart';
import '../../../../core/services/audio_service.dart';

class CelebrationStep extends ConsumerStatefulWidget {
  final Lesson lesson;

  const CelebrationStep({super.key, required this.lesson});

  @override
  ConsumerState<CelebrationStep> createState() => _CelebrationStepState();
}

class _CelebrationStepState extends ConsumerState<CelebrationStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();
  int _lastXp = 0;
  int _lastCoins = 0;

  String _getSuccessOutcome(Lesson lesson) {
    if (lesson.id == 'day_1' || lesson.id.contains('basics')) {
      return 'introduce yourself and greet locals in Kannada!';
    } else if (lesson.id == 'day_2' || lesson.id.contains('greetings')) {
      return 'greet people and start polite conversation!';
    } else if (lesson.id == 'day_3' || lesson.id.contains('travel')) {
      return 'ask for directions and buy tickets for local transport!';
    } else if (lesson.id == 'day_4' || lesson.id.contains('restaurant')) {
      return 'confidently order food and pay at a local Darshini!';
    } else if (lesson.id == 'day_5' || lesson.id.contains('workplace')) {
      return 'chat with office colleagues and make daily plans!';
    }
    return '${lesson.subtitle.toLowerCase()} confidently!';
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(() {
            _updateParticles();
          });

    // Generate initial particles
    for (int i = 0; i < 70; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: -_random.nextDouble() * 0.5, // Start above the screen
          size: _random.nextDouble() * 8 + 6,
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)]
              .withOpacity(0.85),
          speed: _random.nextDouble() * 0.01 + 0.005,
          drift: _random.nextDouble() * 0.02 - 0.01,
        ),
      );
    }

    _animationController.forward();
    
    // Play success fanfare on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.instance.playSuccess();
    });
  }

  void _updateParticles() {
    // Rebuilt by AnimatedBuilder ticker, coordinates updated safely.
    for (final p in _particles) {
      p.y += p.speed;
      p.x += p.drift;
      // Keep within bounds
      if (p.x < 0) p.x = 1.0;
      if (p.x > 1) p.x = 0.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = ref.watch(userProgressProvider);
    final int lvl = progress.calculatedLevel;
    final double pct = progress.percentToNextLevel;

    return Stack(
      children: [
        // Confetti Canvas Layer
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ConfettiPainter(particles: _particles),
                );
              },
            ),
          ),
        ),

        // Main UI Elements
        Column(
          children: [
            MittuCompanionHeader(
              message:
                  "Now you can ${_getSuccessOutcome(widget.lesson)}\n\nMittu is doing the happy elephant dance! Time to celebrate! 🐘🎉✨",
              mood: MittuMood.waving,
              size: 110,
            ),
            const SizedBox(height: 12),

            // Animated Level Progress Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.glassCardDecoration(
                context: context,
                radius: 20,
              ),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1800),
                tween: Tween<double>(begin: 0.0, end: pct),
                builder: (context, value, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: isDark
                              ? AppTheme.darkBorder
                              : Colors.grey[200],
                          color: AppTheme.successGreen,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LEVEL $lvl',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${(value * 100).toInt()}% toward LEVEL ${lvl + 1}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'LEVEL ${lvl + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Animated Reward Summary Cards (Counting up ticker with scale transitions)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<int>(
                  duration: const Duration(milliseconds: 1500),
                  tween: IntTween(begin: 0, end: widget.lesson.xpReward),
                  builder: (context, val, child) {
                    if (val != _lastXp) {
                      _lastXp = val;
                      if (val % 2 == 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          AudioService.instance.playXPCount();
                        });
                      }
                    }
                    final isComplete = val == widget.lesson.xpReward;
                    return AnimatedScale(
                      scale: isComplete ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: _buildRewardCard(
                        '+$val XP',
                        Icons.bolt,
                        Colors.orange,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                TweenAnimationBuilder<int>(
                  duration: const Duration(milliseconds: 1500),
                  tween: IntTween(begin: 0, end: widget.lesson.coinReward),
                  builder: (context, val, child) {
                    if (val != _lastCoins) {
                      _lastCoins = val;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        AudioService.instance.playPop();
                      });
                    }
                    final isComplete = val == widget.lesson.coinReward;
                    return AnimatedScale(
                      scale: isComplete ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: _buildRewardCard(
                        '+$val Coins',
                        Icons.monetization_on,
                        Colors.amber,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardCard(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  final double size;
  final Color color;
  final double speed;
  final double drift;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.drift,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.y < 0 || p.y > 1) continue;
      final paint = Paint()..color = p.color;
      final px = p.x * size.width;
      final py = p.y * size.height;
      // Draw rectangular confetti particles for a premium look
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(px, py),
          width: p.size,
          height: p.size * 0.6,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
