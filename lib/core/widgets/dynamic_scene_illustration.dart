import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DynamicSceneIllustration extends StatefulWidget {
  final String imagePath;
  final int stepIndex;
  final bool forceRain;
  final double height;
  final bool disableNight;

  const DynamicSceneIllustration({
    super.key,
    required this.imagePath,
    this.stepIndex = 0,
    this.forceRain = false,
    this.height = 185.0,
    this.disableNight = false,
  });

  @override
  State<DynamicSceneIllustration> createState() => _DynamicSceneIllustrationState();
}

class _DynamicSceneIllustrationState extends State<DynamicSceneIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _rainController;
  late List<_RainDrop> _rainDrops;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Animation controller for falling rain
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _rainDrops = List.generate(35, (index) => _generateRandomDrop());
  }

  _RainDrop _generateRandomDrop() {
    return _RainDrop(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: 1.5 + _random.nextDouble() * 2.0,
      length: 8.0 + _random.nextDouble() * 12.0,
      opacity: 0.15 + _random.nextDouble() * 0.35,
    );
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
  }

  // Determine time of day based on current clock hour or step progression
  int getHour() {
    // If stepIndex is set (>0), we can map steps to simulated time progression (morning -> afternoon -> evening -> night)
    if (widget.stepIndex > 0) {
      if (widget.stepIndex <= 3) return 8;   // Morning (8 AM)
      if (widget.stepIndex <= 7) return 13;  // Afternoon (1 PM)
      if (widget.stepIndex <= 11) return 18; // Evening (6 PM)
      return 21;                             // Night (9 PM)
    }
    return DateTime.now().hour;
  }

  bool isMorning(int hour) => hour >= 6 && hour < 12;
  bool isAfternoon(int hour) => hour >= 12 && hour < 17;
  bool isEvening(int hour) => hour >= 17 && hour < 20;
  bool isNight(int hour) => hour >= 20 || hour < 6;

  // Check if it's currently raining (e.g. simulated or system clock)
  bool isRaining() {
    if (widget.forceRain) return true;
    // Simulate rain based on minutes to keep it organic
    return DateTime.now().minute % 5 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final hour = getHour();
    final bool raining = isRaining();

    // 1. Tints
    Widget? tintOverlay;
    String timeBadge = "☀️ Day";

    if (isMorning(hour)) {
      timeBadge = "🌅 Morning";
      tintOverlay = Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFBBF24).withOpacity(0.06), // Warm yellow tint
        ),
      );
    } else if (isAfternoon(hour)) {
      timeBadge = "☀️ Afternoon";
      tintOverlay = Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04), // Clear bright tint
        ),
      );
    } else if (isEvening(hour)) {
      timeBadge = "🌇 Sunset Glow";
      tintOverlay = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF97316).withOpacity(0.35),
              const Color(0xFFEC4899).withOpacity(0.18),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    } else if (isNight(hour)) {
      if (widget.disableNight) {
        timeBadge = "☀️ Day";
        tintOverlay = null; // No night filter
      } else {
        timeBadge = "🌃 Night";
        tintOverlay = Stack(
          children: [
            // Indigo translucent overlay
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E).withOpacity(0.20),
              ),
            ),
            // Custom Painter for glowing night stars
            Positioned.fill(
              child: CustomPaint(
                painter: _StarsPainter(randomSeed: widget.imagePath.hashCode),
              ),
            ),
          ],
        );
      }
    }

    final isDarkCard = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            color: isDarkCard ? AppTheme.darkCard : Colors.grey[100],
            height: widget.height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base Image
                Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fail-safe default
                    return Container(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      child: const Center(
                        child: Icon(
                          Icons.image_search_rounded,
                          size: 40,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    );
                  },
                ),

                // Time of Day Filter Overlay
                if (tintOverlay != null) tintOverlay,

                // Rainy Weather Overlay
                if (raining)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _rainController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _RainPainter(
                            drops: _rainDrops,
                            animationValue: _rainController.value,
                            random: _random,
                            regenerate: _generateRandomDrop,
                          ),
                        );
                      },
                    ),
                  ),

                // Environmental / Status Badges on top
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (raining) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: const Text(
                            "🌧️ Raining",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Scene descriptor badge at bottom
                if (widget.stepIndex > 0)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Scene ${widget.stepIndex} / 15",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RainDrop {
  double x; // Horizontal percentage (0 to 1)
  double y; // Vertical percentage (0 to 1)
  double speed;
  double length;
  double opacity;

  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
  });
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double animationValue;
  final Random random;
  final _RainDrop Function() regenerate;

  _RainPainter({
    required this.drops,
    required this.animationValue,
    required this.random,
    required this.regenerate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2;

    for (var drop in drops) {
      // Calculate active falling coordinates
      double dx = drop.x * size.width;
      double dy = (drop.y + animationValue * drop.speed) % 1.0 * size.height;

      // Draw slightly diagonal streaks for windy look
      paint.color = Colors.white.withOpacity(drop.opacity);
      canvas.drawLine(
        Offset(dx, dy),
        Offset(dx - 1.5, dy + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StarsPainter extends CustomPainter {
  final int randomSeed;

  _StarsPainter({required this.randomSeed});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(randomSeed);
    final paint = Paint()..color = Colors.white.withOpacity(0.6);

    // Draw 15 static twinkling stars on the night overlay
    for (int i = 0; i < 15; i++) {
      double sx = rand.nextDouble() * size.width;
      double sy = rand.nextDouble() * size.height;
      double radius = 0.8 + rand.nextDouble() * 1.5;
      
      // Twinkle effect: alternate paint transparency slightly
      paint.color = Colors.white.withOpacity(0.3 + rand.nextDouble() * 0.5);
      canvas.drawCircle(Offset(sx, sy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
