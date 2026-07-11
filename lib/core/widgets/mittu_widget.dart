import 'dart:math';
import 'package:flutter/material.dart';
import '../database/local_db.dart';

enum MittuMood { neutral, happy, waving, sad, reading }

class MittuWidget extends StatefulWidget {
  final MittuMood mood;
  final double size;
  final bool animate;
  final String? equippedAccessoryOverride;

  const MittuWidget({
    super.key,
    this.mood = MittuMood.neutral,
    this.size = 180.0,
    this.animate = true,
    this.equippedAccessoryOverride,
  });

  static MittuMood fromString(String? state) {
    if (state == null) return MittuMood.neutral;
    switch (state.toLowerCase()) {
      case 'mittu_wave':
      case 'wave':
      case 'waving':
        return MittuMood.waving;
      case 'mittu_happy':
      case 'happy':
        return MittuMood.happy;
      case 'mittu_sad':
      case 'sad':
        return MittuMood.sad;
      case 'mittu_reading':
      case 'reading':
        return MittuMood.reading;
      case 'mittu_talking':
      case 'talking':
        return MittuMood.waving;
      case 'mittu_idle':
      case 'idle':
      default:
        return MittuMood.neutral;
    }
  }

  @override
  State<MittuWidget> createState() => _MittuWidgetState();
}

class _MittuWidgetState extends State<MittuWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  MittuMood? _tempMood;

  void _handleTap() {
    if (_tempMood != null) return;
    setState(() {
      _tempMood = Random().nextBool() ? MittuMood.waving : MittuMood.happy;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _tempMood = null;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MittuWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
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
        // Base bounce offset (breathing float) and transform parameters
        double bounceOffset = 0.0;
        double rotationAngle = 0.0;
        double scaleMultiplier = 1.0;
        double opacityMultiplier = 1.0;

        final activeMood = _tempMood ?? widget.mood;

        if (widget.animate) {
          switch (activeMood) {
            case MittuMood.happy:
              // Fast bouncy vertical movement
              bounceOffset = sin(_controller.value * pi * 2) * 8.0;
              scaleMultiplier =
                  1.0 + (sin(_controller.value * pi * 2) * 0.05).abs();
              break;
            case MittuMood.waving:
              // Bouncing and rotational waving wobble
              bounceOffset = sin(_controller.value * pi * 2) * 4.0;
              rotationAngle = sin(_controller.value * pi * 2) * 0.08;
              break;
            case MittuMood.sad:
              // Slow droopy sink
              bounceOffset = 3.0 + sin(_controller.value * pi * 1) * 2.0;
              rotationAngle = 0.04;
              opacityMultiplier = 0.85;
              scaleMultiplier = 0.95;
              break;
            case MittuMood.reading:
              // Forward tilt (focused reading look)
              bounceOffset = sin(_controller.value * pi * 2) * 2.0;
              rotationAngle = -0.05;
              break;
            case MittuMood.neutral:
            default:
              // Gentle float
              bounceOffset = sin(_controller.value * pi * 2) * 3.0;
              break;
          }
        }

        final String equipped = widget.equippedAccessoryOverride ?? LocalDb.equippedAccessory;

        return GestureDetector(
          onTap: _handleTap,
          child: Container(
            width: widget.size,
            height: widget.size,
            transform: Matrix4.translationValues(0, bounceOffset, 0)
              ..scale(scaleMultiplier),
            child: Transform.rotate(
              angle: rotationAngle,
              child: Opacity(
                opacity: opacityMultiplier,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/mittu.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: MittuPainter(
                            mood: activeMood,
                            waveAngle: rotationAngle,
                            isDark: Theme.of(context).brightness == Brightness.dark,
                            equippedAccessory: equipped,
                            onlyDrawAccessory: false,
                            animationValue: _controller.value,
                          ),
                        );
                      },
                    ),
                    if (equipped.isNotEmpty && equipped != 'circus_hat')
                      Positioned.fill(
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: MittuPainter(
                            mood: activeMood,
                            waveAngle: rotationAngle,
                            isDark: Theme.of(context).brightness == Brightness.dark,
                            equippedAccessory: equipped,
                            onlyDrawAccessory: true,
                            animationValue: _controller.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MittuPainter extends CustomPainter {
  final MittuMood mood;
  final double waveAngle;
  final bool isDark;
  final String equippedAccessory;
  final bool onlyDrawAccessory;
  final double animationValue;

  MittuPainter({
    required this.mood,
    required this.waveAngle,
    required this.isDark,
    this.equippedAccessory = '',
    this.onlyDrawAccessory = false,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final blackOutline = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    if (!onlyDrawAccessory) {
      final center = Offset(w / 2, h / 2);
      final elephantColor = Paint()
        ..color = const Color(0xFF93C5FD)
        ..style = PaintingStyle.fill;
      final innerEarColor = Paint()
        ..color = const Color(0xFFFCA5A5)
        ..style = PaintingStyle.fill;
      final whitePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final eyePupilPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;

      final earWobble = sin(animationValue * pi * 2) * 0.03;

      // Draw Ears first (so they sit behind the head)
      // Left Ear
      canvas.save();
      canvas.translate(w * 0.21, h * 0.44);
      canvas.rotate(-earWobble);
      canvas.translate(-w * 0.21, -h * 0.44);
      final leftEarPath = Path()
        ..addOval(Rect.fromLTWH(w * 0.05, h * 0.22, w * 0.32, h * 0.45));
      canvas.drawPath(leftEarPath, elephantColor);
      canvas.drawPath(leftEarPath, blackOutline);

      final innerLeftEarPath = Path()
        ..addOval(Rect.fromLTWH(w * 0.12, h * 0.28, w * 0.20, h * 0.32));
      canvas.drawPath(innerLeftEarPath, innerEarColor);
      canvas.restore();

      // Right Ear (might wave if mood is waving)
      canvas.save();
      if (mood == MittuMood.waving) {
        canvas.translate(w * 0.7, h * 0.4);
        canvas.rotate(waveAngle);
        canvas.translate(-w * 0.7, -h * 0.4);
      } else {
        canvas.translate(w * 0.79, h * 0.44);
        canvas.rotate(earWobble);
        canvas.translate(-w * 0.79, -h * 0.44);
      }
      final rightEarPath = Path()
        ..addOval(Rect.fromLTWH(w * 0.63, h * 0.22, w * 0.32, h * 0.45));
      canvas.drawPath(rightEarPath, elephantColor);
      canvas.drawPath(rightEarPath, blackOutline);

      final innerRightEarPath = Path()
        ..addOval(Rect.fromLTWH(w * 0.68, h * 0.28, w * 0.20, h * 0.32));
      canvas.drawPath(innerRightEarPath, innerEarColor);
      canvas.restore();

      // Draw Body (sitting down shape with soft breathing scale)
      final bodyPaint = Paint()
        ..color = const Color(0xFF93C5FD)
        ..style = PaintingStyle.fill;
      final double bodyOffsetV = sin(animationValue * pi * 2) * 1.2;
      final bodyPath = Path()
        ..moveTo(w * 0.32, h * 0.85)
        ..quadraticBezierTo(w * 0.3, h * 0.6 + bodyOffsetV, w * 0.5, h * 0.6 + bodyOffsetV)
        ..quadraticBezierTo(w * 0.7, h * 0.6 + bodyOffsetV, w * 0.68, h * 0.85)
        ..close();
      canvas.drawPath(bodyPath, bodyPaint);
      canvas.drawPath(bodyPath, blackOutline);

      // Collar (Red/Yellow ruffle)
      final collarPaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      final collarPath = Path()
        ..moveTo(w * 0.32, h * 0.65 + bodyOffsetV)
        ..quadraticBezierTo(w * 0.5, h * 0.75 + bodyOffsetV, w * 0.68, h * 0.65 + bodyOffsetV)
        ..quadraticBezierTo(w * 0.5, h * 0.62 + bodyOffsetV, w * 0.32, h * 0.65 + bodyOffsetV)
        ..close();
      canvas.drawPath(collarPath, collarPaint);
      canvas.drawPath(collarPath, blackOutline);

      // Head
      final headRect = Rect.fromLTWH(w * 0.26, h * 0.20, w * 0.48, h * 0.45);
      canvas.drawOval(headRect, elephantColor);
      canvas.drawOval(headRect, blackOutline);

      // Eye Blinking & Looking around details
      final bool isBlinking = mood != MittuMood.sad && (animationValue >= 0.15 && animationValue <= 0.21);

      if (isBlinking) {
        final eyePaint = Paint()
          ..color = const Color(0xFF1E293B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;

        // Left closed eye arc
        canvas.drawArc(
          Rect.fromLTWH(w * 0.38, h * 0.35, w * 0.07, h * 0.04),
          0,
          pi,
          false,
          eyePaint,
        );
        // Right closed eye arc
        canvas.drawArc(
          Rect.fromLTWH(w * 0.55, h * 0.35, w * 0.07, h * 0.04),
          0,
          pi,
          false,
          eyePaint,
        );
      } else {
        // Eyes
        final leftEyeRect = Rect.fromLTWH(w * 0.38, h * 0.32, w * 0.07, h * 0.10);
        final rightEyeRect = Rect.fromLTWH(w * 0.55, h * 0.32, w * 0.07, h * 0.10);

        canvas.drawOval(leftEyeRect, whitePaint);
        canvas.drawOval(leftEyeRect, blackOutline);
        canvas.drawOval(rightEyeRect, whitePaint);
        canvas.drawOval(rightEyeRect, blackOutline);

        // Pupils
        double pupilOffsetH = 0.0;
        double pupilOffsetV = 0.0;
        if (mood == MittuMood.happy) {
          pupilOffsetV = -2.0;
        } else if (mood == MittuMood.sad) {
          pupilOffsetV = 2.0;
        } else if (mood == MittuMood.neutral) {
          if (animationValue > 0.75) {
            pupilOffsetH = 2.0; // Look right
          } else if (animationValue < 0.25) {
            pupilOffsetH = -2.0; // Look left
          }
        }

        final leftPupil = Rect.fromLTWH(
          w * 0.40 + pupilOffsetH,
          h * 0.34 + pupilOffsetV,
          w * 0.035,
          h * 0.05,
        );
        final rightPupil = Rect.fromLTWH(
          w * 0.57 + pupilOffsetH,
          h * 0.34 + pupilOffsetV,
          w * 0.035,
          h * 0.05,
        );

        canvas.drawOval(leftPupil, eyePupilPaint);
        canvas.drawOval(rightPupil, eyePupilPaint);

        // Shiny eye dots
        canvas.drawCircle(Offset(w * 0.41 + pupilOffsetH, h * 0.355 + pupilOffsetV), 2, whitePaint);
        canvas.drawCircle(Offset(w * 0.58 + pupilOffsetH, h * 0.355 + pupilOffsetV), 2, whitePaint);
      }

      // Cheeks (blush)
      final blushPaint = Paint()
        ..color = const Color(0xFFF87171).withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(w * 0.34, h * 0.44), w * 0.03, blushPaint);
      canvas.drawCircle(Offset(w * 0.66, h * 0.44), w * 0.03, blushPaint);

      // Trunk
      final trunkPath = Path();
      if (mood == MittuMood.happy || mood == MittuMood.waving) {
        // Curved up trunk
        trunkPath.moveTo(w * 0.5, h * 0.43);
        trunkPath.quadraticBezierTo(w * 0.52, h * 0.55, w * 0.45, h * 0.54);
        trunkPath.quadraticBezierTo(w * 0.38, h * 0.52, w * 0.36, h * 0.44);
        trunkPath.quadraticBezierTo(w * 0.44, h * 0.48, w * 0.48, h * 0.46);
      } else if (mood == MittuMood.sad) {
        // Drooping trunk
        trunkPath.moveTo(w * 0.5, h * 0.43);
        trunkPath.quadraticBezierTo(w * 0.54, h * 0.58, w * 0.56, h * 0.62);
        trunkPath.quadraticBezierTo(w * 0.50, h * 0.63, w * 0.47, h * 0.56);
        trunkPath.quadraticBezierTo(w * 0.46, h * 0.50, w * 0.47, h * 0.43);
      } else {
        // Reading/Neutral slightly curved trunk
        trunkPath.moveTo(w * 0.5, h * 0.43);
        trunkPath.quadraticBezierTo(w * 0.53, h * 0.54, w * 0.50, h * 0.56);
        trunkPath.quadraticBezierTo(w * 0.46, h * 0.54, w * 0.47, h * 0.43);
      }
      canvas.drawPath(trunkPath, elephantColor);
      canvas.drawPath(trunkPath, blackOutline);
    }

    // Draw the accessory
    if (equippedAccessory.isEmpty || equippedAccessory == 'circus_hat') {
      if (!onlyDrawAccessory) {
        // Hat (Yellow Circus Hat)
        final hatPaint = Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.fill;
        final hatPath = Path()
          ..moveTo(w * 0.44, h * 0.22)
          ..quadraticBezierTo(w * 0.5, h * 0.06, w * 0.5, h * 0.05)
          ..quadraticBezierTo(w * 0.5, h * 0.06, w * 0.56, h * 0.22)
          ..close();
        canvas.drawPath(hatPath, hatPaint);
        canvas.drawPath(hatPath, blackOutline);

        // Red band on hat
        final hatBandPaint = Paint()
          ..color = const Color(0xFFEF4444)
          ..style = PaintingStyle.fill;
        final hatBandPath = Path()
          ..moveTo(w * 0.45, h * 0.20)
          ..quadraticBezierTo(w * 0.5, h * 0.22, w * 0.55, h * 0.20)
          ..lineTo(w * 0.56, h * 0.22)
          ..quadraticBezierTo(w * 0.5, h * 0.24, w * 0.44, h * 0.22)
          ..close();
        canvas.drawPath(hatBandPath, hatBandPaint);

        // Mini crown / puff at top of hat
        canvas.drawCircle(Offset(w * 0.5, h * 0.05), w * 0.02, hatPaint);
        canvas.drawCircle(Offset(w * 0.5, h * 0.05), w * 0.02, blackOutline);
      }
    } else {
      if (equippedAccessory == 'hat' || equippedAccessory == 'graduation_hat') {
        final hatPaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill;
        final borderPaint = Paint()..color = const Color(0xFF000000)..style = PaintingStyle.stroke..strokeWidth = 2.0;
        final goldPaint = Paint()..color = const Color(0xFFFBBF24)..style = PaintingStyle.fill;

        // Rhombus top
        final topPath = Path()
          ..moveTo(w * 0.5, h * 0.09)
          ..lineTo(w * 0.66, h * 0.15)
          ..lineTo(w * 0.5, h * 0.21)
          ..lineTo(w * 0.34, h * 0.15)
          ..close();
        canvas.drawPath(topPath, hatPaint);
        canvas.drawPath(topPath, borderPaint);

        // Under cap stand
        final standPath = Path()
          ..moveTo(w * 0.43, h * 0.17)
          ..lineTo(w * 0.57, h * 0.17)
          ..lineTo(w * 0.55, h * 0.22)
          ..lineTo(w * 0.45, h * 0.22)
          ..close();
        canvas.drawPath(standPath, hatPaint);
        canvas.drawPath(standPath, borderPaint);

        // Tassel
        final tasselPath = Path()
          ..moveTo(w * 0.5, h * 0.15)
          ..lineTo(w * 0.36, h * 0.22)
          ..lineTo(w * 0.35, h * 0.27);
        canvas.drawPath(tasselPath, Paint()..color = const Color(0xFFFBBF24)..style = PaintingStyle.stroke..strokeWidth = 2.5);
        canvas.drawCircle(Offset(w * 0.35, h * 0.27), 4, goldPaint);
      }

      if (equippedAccessory == 'sunglasses') {
        final glassPaint = Paint()..color = const Color(0xDD000000)..style = PaintingStyle.fill;
        final framePaint = Paint()..color = const Color(0xFFF43F5E)..style = PaintingStyle.stroke..strokeWidth = 3.5;

        // Left glass
        final leftRect = Rect.fromLTWH(w * 0.33, h * 0.32, w * 0.12, h * 0.07);
        canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(8)), glassPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(8)), framePaint);

        // Right glass
        final rightRect = Rect.fromLTWH(w * 0.53, h * 0.32, w * 0.12, h * 0.07);
        canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(8)), glassPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(8)), framePaint);

        // Bridge
        canvas.drawLine(Offset(w * 0.45, h * 0.355), Offset(w * 0.53, h * 0.355), framePaint);
      }

      if (equippedAccessory == 'scarf') {
        final scarfPaint = Paint()..color = const Color(0xFFDC2626)..style = PaintingStyle.fill;
        final borderPaint = Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.stroke..strokeWidth = 2.0;

        final scarfPath = Path()
          ..moveTo(w * 0.30, h * 0.62)
          ..quadraticBezierTo(w * 0.5, h * 0.70, w * 0.70, h * 0.62)
          ..quadraticBezierTo(w * 0.72, h * 0.68, w * 0.66, h * 0.70)
          ..quadraticBezierTo(w * 0.5, h * 0.72, w * 0.34, h * 0.70)
          ..close();
        canvas.drawPath(scarfPath, scarfPaint);
        canvas.drawPath(scarfPath, borderPaint);

        // Tail hanging down
        final tailPath = Path()
          ..moveTo(w * 0.58, h * 0.68)
          ..lineTo(w * 0.62, h * 0.82)
          ..lineTo(w * 0.52, h * 0.82)
          ..lineTo(w * 0.50, h * 0.68)
          ..close();
        canvas.drawPath(tailPath, scarfPaint);
        canvas.drawPath(tailPath, borderPaint);
      }

      if (equippedAccessory == 'crown') {
        final goldPaint = Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.fill;
        final borderPaint = Paint()..color = const Color(0xFF78350F)..style = PaintingStyle.stroke..strokeWidth = 2.0;
        final gemRed = Paint()..color = const Color(0xFFEF4444)..style = PaintingStyle.fill;
        final gemBlue = Paint()..color = const Color(0xFF3B82F6)..style = PaintingStyle.fill;

        final crownPath = Path()
          ..moveTo(w * 0.36, h * 0.20)
          // Point 1
          ..lineTo(w * 0.34, h * 0.10)
          ..lineTo(w * 0.42, h * 0.16)
          // Center point
          ..lineTo(w * 0.50, h * 0.06)
          ..lineTo(w * 0.58, h * 0.16)
          // Point 3
          ..lineTo(w * 0.66, h * 0.10)
          ..lineTo(w * 0.64, h * 0.20)
          ..close();
        canvas.drawPath(crownPath, goldPaint);
        canvas.drawPath(crownPath, borderPaint);

        // Gems on the points
        canvas.drawCircle(Offset(w * 0.34, h * 0.10), 3, gemRed);
        canvas.drawCircle(Offset(w * 0.50, h * 0.06), 4, gemBlue);
        canvas.drawCircle(Offset(w * 0.66, h * 0.10), 3, gemRed);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MittuPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.waveAngle != waveAngle ||
        oldDelegate.isDark != isDark ||
        oldDelegate.equippedAccessory != equippedAccessory ||
        oldDelegate.onlyDrawAccessory != onlyDrawAccessory ||
        oldDelegate.animationValue != animationValue;
  }
}
