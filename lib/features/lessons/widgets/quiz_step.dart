import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/mittu_companion_header.dart';
import '../../../../core/widgets/mittu_widget.dart';
import '../../../../core/widgets/interactive_option_tile.dart';
import '../../../../models/lesson.dart';

class QuizStep extends StatelessWidget {
  final Lesson lesson;
  final int currentQuizQuestionIndex;
  final int selectedQuizAnswerIndex;
  final bool quizChecked;
  final Function(int) onOptionSelected;
  final int comboStreak;

  const QuizStep({
    super.key,
    required this.lesson,
    required this.currentQuizQuestionIndex,
    required this.selectedQuizAnswerIndex,
    required this.quizChecked,
    required this.onOptionSelected,
    required this.comboStreak,
  });

  @override
  Widget build(BuildContext context) {
    if (lesson.quiz.isEmpty) return const SizedBox();
    final quiz =
        lesson.quiz[currentQuizQuestionIndex.clamp(0, lesson.quiz.length - 1)];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Direct, instruction-free question text or motivational feedback praise from Mittu
    String mittuQuestionMessage = '';
    if (quizChecked) {
      final isCorrect = selectedQuizAnswerIndex != -1 &&
          quiz.options[selectedQuizAnswerIndex] == quiz.correctAnswer;
      if (isCorrect) {
        if (comboStreak >= 3) {
          mittuQuestionMessage = "IN-CRE-DI-BLE! $comboStreak IN A ROW! You are a Kannada genius! 🔥🐘";
        } else if (comboStreak == 2) {
          mittuQuestionMessage = "Combo x2! Amazing work, keep this streak going! 🌟🐘";
        } else {
          mittuQuestionMessage = "That's correct! Brilliant! You're making Mittu proud! 🎉🐘";
        }
      } else {
        mittuQuestionMessage = "No worries! Let's learn: the correct answer is \"${quiz.correctAnswer}\". You've got this! 💪🐘";
      }
    } else {
      if (quiz.type == 'listening') {
        mittuQuestionMessage = "Translate this audio clip";
      } else {
        mittuQuestionMessage = quiz.questionText;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question is the primary focus of the screen with a clear, large visual hierarchy
        MittuCompanionHeader(
          message: mittuQuestionMessage,
          mood: MittuMood.happy,
          size: 90,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 36),

        if (quiz.type == 'listening') ...[
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                AudioService.instance.speakKannada(quiz.questionText);
              },
              icon: const Icon(Icons.volume_up_rounded, size: 32),
              label: const Text(
                'Play Audio Clip',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],

        ...List.generate(quiz.options.length, (idx) {
          final opt = quiz.options[idx];
          final isSelected = selectedQuizAnswerIndex == idx;
          final String optionLetter = String.fromCharCode(65 + idx);

          final cleanOpt = opt.trim().toLowerCase();
          final cleanCorrect = (quiz.correctAnswer ?? '').trim().toLowerCase();
          final isCorrectMatch = cleanOpt == cleanCorrect;

          Color borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
          Color bgCol = isDark ? AppTheme.darkCard : Colors.white;
          Color badgeBg = isDark ? Colors.grey[800]! : Colors.grey[200]!;
          Color badgeText = isDark ? Colors.white70 : Colors.black87;

          if (isSelected) {
            borderCol = AppTheme.secondaryOrange;
            bgCol = AppTheme.secondaryOrange.withOpacity(0.08);
            badgeBg = AppTheme.secondaryOrange;
            badgeText = Colors.white;
          }

          if (quizChecked) {
            if (isCorrectMatch) {
              borderCol = AppTheme.successGreen;
              bgCol = AppTheme.successGreen.withOpacity(0.1);
              badgeBg = AppTheme.successGreen;
              badgeText = Colors.white;
            } else if (isSelected) {
              borderCol = AppTheme.errorRed;
              bgCol = AppTheme.errorRed.withOpacity(0.1);
              badgeBg = AppTheme.errorRed;
              badgeText = Colors.white;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: InteractiveOptionTile(
              backgroundColor: bgCol,
              borderColor: borderCol,
              disabled: quizChecked,
              onTap: () => onOptionSelected(idx),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                onTap: null,
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    optionLetter,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: badgeText,
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
                trailing: isSelected
                    ? Icon(
                        quizChecked
                            ? (isCorrectMatch
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded)
                            : Icons.check_circle_rounded,
                        color: quizChecked
                            ? (isCorrectMatch
                                  ? AppTheme.successGreen
                                  : AppTheme.errorRed)
                            : AppTheme.primaryBlue,
                        size: 26,
                      )
                    : (quizChecked && isCorrectMatch
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.successGreen,
                              size: 26,
                            )
                          : null),
              ),
            ),
          );
        }),
        if (quizChecked &&
            selectedQuizAnswerIndex >= 0 &&
            selectedQuizAnswerIndex < quiz.options.length &&
            quiz.options[selectedQuizAnswerIndex].trim().toLowerCase() != (quiz.correctAnswer ?? '').trim().toLowerCase()) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.errorRed.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.errorRed,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Incorrect Answer Hint',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.errorRed,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "The correct answer is '${quiz.correctAnswer}'. Try reviewing the vocabulary words or check pronunciation to find the correct translation!",
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
