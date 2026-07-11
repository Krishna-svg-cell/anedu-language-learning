import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/lesson.dart';
import '../../../core/widgets/mittu_widget.dart';
import '../../../core/widgets/interactive_option_tile.dart';
import '../../../core/services/audio_service.dart';

class WarmUpQuestionStep extends StatefulWidget {
  final Lesson lesson;
  final ValueChanged<bool> onCompleted;
  final Function(bool isCorrect)? onAnswered;

  const WarmUpQuestionStep({
    super.key,
    required this.lesson,
    required this.onCompleted,
    this.onAnswered,
  });

  @override
  State<WarmUpQuestionStep> createState() => _WarmUpQuestionStepState();
}

class _WarmUpQuestionStepState extends State<WarmUpQuestionStep> {
  int _selectedIndex = -1;
  bool _answered = false;

  final List<String> _defaultOptions = [
    'How do you say goodbye?',
    'How do you say "Namaskara" to greet?',
    'How do you ask for the bill?',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final correctAnswer = widget.lesson.quiz.isNotEmpty
        ? widget.lesson.quiz[0].correctAnswer
        : _defaultOptions[1];

    final options = widget.lesson.quiz.isNotEmpty
        ? widget.lesson.quiz[0].options
        : _defaultOptions;

    String question = '';
    if (_answered) {
      final isCorrect = _selectedIndex != -1 && options[_selectedIndex] == correctAnswer;
      if (isCorrect) {
        question = "That's correct! Brilliant start to our daily mission! 🎉🐘";
      } else {
        question = "No worries! Let's learn: the correct answer is \"$correctAnswer\". You've got this! 💪🐘";
      }
    } else {
      question = widget.lesson.quiz.isNotEmpty
          ? widget.lesson.quiz[0].questionText
          : 'Do you know what this daily mission will focus on?';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mittu prompt displaying the question directly in large bold font
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MittuWidget(mood: MittuMood.neutral, size: 70, animate: true),
            const SizedBox(width: 8),
            Expanded(
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
                  question,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // Multiple choice list with large touch targets and high-readability text
        ...List.generate(options.length, (index) {
          final opt = options[index];
          final isSelected = _selectedIndex == index;
          final isCorrect = opt == correctAnswer;

          Color borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
          Color bgCol = isDark ? AppTheme.darkCard : Colors.white;
          Widget? trailing;

          if (_answered) {
            if (isCorrect) {
              borderCol = AppTheme.successGreen;
              bgCol = AppTheme.successGreen.withOpacity(0.08);
              trailing = const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 26);
            } else if (isSelected) {
              borderCol = AppTheme.errorRed;
              bgCol = AppTheme.errorRed.withOpacity(0.08);
              trailing = const Icon(Icons.cancel_rounded, color: AppTheme.errorRed, size: 26);
            }
          } else if (isSelected) {
            borderCol = AppTheme.secondaryOrange;
            bgCol = AppTheme.secondaryOrange.withOpacity(0.05);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InteractiveOptionTile(
              backgroundColor: bgCol,
              borderColor: borderCol,
              disabled: _answered,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                  _answered = true;
                });
                if (isCorrect) {
                  AudioService.instance.playCorrect();
                  widget.onAnswered?.call(true);
                } else {
                  AudioService.instance.playIncorrect();
                  widget.onAnswered?.call(false);
                }
                widget.onCompleted(true);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                onTap: null,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.secondaryOrange : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? AppTheme.secondaryOrange : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  opt,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  ),
                ),
                trailing: trailing,
              ),
            ),
          );
        }),
      ],
    );
  }
}
