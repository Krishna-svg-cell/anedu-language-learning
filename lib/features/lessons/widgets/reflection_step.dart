import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/lesson.dart';
import '../../../core/widgets/mittu_widget.dart';

class ReflectionStep extends StatefulWidget {
  final Lesson lesson;
  final ValueChanged<bool> onCompleted;

  const ReflectionStep({
    super.key,
    required this.lesson,
    required this.onCompleted,
  });

  @override
  State<ReflectionStep> createState() => _ReflectionStepState();
}

class _ReflectionStepState extends State<ReflectionStep> {
  double _confidenceValue = 3.0;
  bool _touched = false;

  final List<Map<String, String>> _statusEmojis = [
    {'e': '😰', 't': 'Terrified'},
    {'e': '😕', 't': 'Nervous'},
    {'e': '🙂', 't': 'Capable'},
    {'e': '😀', 't': 'Confident'},
    {'e': '😎', 't': 'Ready to Survive!'},
  ];

  @override
  void initState() {
    super.initState();
    // Enable going forward immediately since it is a self-assessment feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCompleted(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int statusIndex = (_confidenceValue - 1).round().clamp(0, 4);
    final status = _statusEmojis[statusIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mittu wishes you well
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MittuWidget(mood: MittuMood.happy, size: 70, animate: true),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.premiumShadow(isDark: isDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Awesome job completing today's mission! 🎉",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _touched
                          ? "Mastering Kannada is all about confidence. Keep practicing this daily survival conversation!"
                          : "How confident do you feel applying this scenario in daily life across Karnataka?",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // Confidence scale display box
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                status['e']!,
                style: const TextStyle(fontSize: 54),
              ),
              const SizedBox(height: 12),
              Text(
                status['t']!.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 28),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppTheme.primaryBlue,
                  inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  thumbColor: AppTheme.primaryBlue,
                  overlayColor: AppTheme.primaryBlue.withOpacity(0.1),
                  valueIndicatorColor: AppTheme.primaryBlue,
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: _confidenceValue,
                  min: 1.0,
                  max: 5.0,
                  divisions: 4,
                  onChanged: (val) {
                    setState(() {
                      _confidenceValue = val;
                      _touched = true;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('😰 Nervous', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                    Text('🙂 Able', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                    Text('😎 Ready!', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
