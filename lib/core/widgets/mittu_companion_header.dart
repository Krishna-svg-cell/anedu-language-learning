import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'mittu_widget.dart';

class MittuCompanionHeader extends StatelessWidget {
  final String message;
  final MittuMood mood;
  final double size;
  final TextStyle? style;

  const MittuCompanionHeader({
    super.key,
    required this.message,
    this.mood = MittuMood.neutral,
    this.size = 80.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MittuWidget(mood: mood, size: size, animate: true),
          const SizedBox(width: 12),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  alignment: Alignment.bottomLeft,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
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
                child: Text(
                  message,
                  style: style ?? const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
