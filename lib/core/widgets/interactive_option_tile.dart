import 'package:flutter/material.dart';
import 'animated_pressable.dart';

class InteractiveOptionTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool disabled;

  const InteractiveOptionTile({
    super.key,
    required this.child,
    this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 20.0,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPressable(
      onTap: disabled ? null : onTap,
      scaleFactor: 0.97,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
