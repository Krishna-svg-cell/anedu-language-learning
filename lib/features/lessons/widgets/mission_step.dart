import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mittu_companion_header.dart';
import '../../../../core/widgets/mittu_widget.dart';
import '../../../../models/lesson.dart';

class MissionStep extends StatelessWidget {
  final Lesson lesson;

  const MissionStep({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MittuCompanionHeader(
          message:
              "Here is your real-life challenge! Complete this mission outside the app today to lock in your learning! Mittu believes in you! 🐘🚀",
          mood: MittuMood.happy,
          size: 100,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassCardDecoration(
            context: context,
            radius: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rocket_launch_rounded,
                    color: AppTheme.secondaryOrange,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TODAY\'S CHALLENGE',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondaryOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Complete this mission in real life:',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryOrange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  lesson.missionDescription,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.secondaryOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
