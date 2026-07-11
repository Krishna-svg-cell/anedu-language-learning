import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiCelebration extends StatefulWidget {
  final bool trigger;
  const ConfettiCelebration({super.key, required this.trigger});

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        _updateParticles();
      });
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && widget.trigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _spawnParticles();
        }
      });
    }
  }

  void _spawnParticles() {
    _particles.clear();
    final colors = [
      const Color(0xFF3B82F6), // Vibrant blue
      const Color(0xFF10B981), // Emerald green
      const Color(0xFFF59E0B), // Amber yellow
      const Color(0xFFEF4444), // Coral red
      const Color(0xFFEC4899), // Hot pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFF97316), // Orange
    ];
    // Spawn 100 particles
    for (int i = 0; i < 100; i++) {
      _particles.add(
        _ConfettiParticle(
          x: (_random.nextDouble() - 0.5) * 500, // span out horizontally
          y: -20, // start just above screen
          vx: (_random.nextDouble() - 0.5) * 12,
          vy: _random.nextDouble() * 8 + 4,
          color: colors[_random.nextInt(colors.length)],
          size: _random.nextDouble() * 10 + 6,
          rotation: _random.nextDouble() * pi * 2,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.15,
        ),
      );
    }
    _controller.forward(from: 0.0);
  }

  void _updateParticles() {
    // No setState here, coordinates updated on ticker/animation ticks.
    // AnimatedBuilder handles paint triggering automatically.
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.22;
      p.rotation += p.rotationSpeed;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_particles.isEmpty || !_controller.isAnimating) return const SizedBox();
        return IgnorePointer(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_particles),
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final double realX = (size.width / 2) + p.x;
      if (realX < -20 || realX > size.width + 20 || p.y > size.height + 20) {
        continue;
      }

      paint.color = p.color;
      canvas.save();
      canvas.translate(realX, p.y);
      canvas.rotate(p.rotation);

      // Draw particle: either a rectangle or a small star shape
      final double half = p.size / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(-half, -half / 2, half, half / 2),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
