import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'mittu_widget.dart';

class MittuSlideUpOverlay extends StatefulWidget {
  final bool visible;
  final String message;
  final MittuMood mood;
  final VoidCallback? onDismiss;

  const MittuSlideUpOverlay({
    super.key,
    required this.visible,
    required this.message,
    this.mood = MittuMood.neutral,
    this.onDismiss,
  });

  @override
  State<MittuSlideUpOverlay> createState() => _MittuSlideUpOverlayState();
}

class _MittuSlideUpOverlayState extends State<MittuSlideUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.2), // Start fully below the viewport
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    if (widget.visible) {
      _slideController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant MittuSlideUpOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _slideController.forward();
    } else if (!widget.visible && oldWidget.visible) {
      _slideController.reverse().then((_) {
        if (widget.onDismiss != null) {
          widget.onDismiss!();
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SlideTransition(
      position: _offsetAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1.5,
            ),
            boxShadow: AppTheme.premiumShadow(isDark: isDark),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mittu mascot widget
              MittuWidget(
                mood: widget.mood,
                size: 70,
                animate: true,
              ),
              const SizedBox(width: 14),
              
              // Speech bubble message
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "MITTU",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.grey[400] : AppTheme.primaryBlue,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Close button
              if (widget.onDismiss != null)
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.black45,
                    size: 18,
                  ),
                  onPressed: widget.onDismiss,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
