import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/mittu_companion_header.dart';
import '../../../../core/widgets/mittu_widget.dart';
import '../../../../models/lesson.dart';

class FlashcardsStep extends StatefulWidget {
  final Lesson lesson;

  const FlashcardsStep({super.key, required this.lesson});

  @override
  State<FlashcardsStep> createState() => _FlashcardsStepState();
}

class _FlashcardsStepState extends State<FlashcardsStep> {
  int _currentFlashcardIndex = 0;
  final Map<int, bool> _flippedCards = {};

  @override
  Widget build(BuildContext context) {
    if (widget.lesson.vocabulary.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final word = widget.lesson.vocabulary[_currentFlashcardIndex];
    final isFlipped = _flippedCards[_currentFlashcardIndex] ?? false;

    return Column(
      children: [
        const MittuCompanionHeader(
          message:
              "Let's test your memory! Tap the card to flip it and reveal the translation. Swipe or tap Next/Prev to move between cards! 🐘🎴",
          mood: MittuMood.happy,
          size: 90,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Card ${_currentFlashcardIndex + 1} of ${widget.lesson.vocabulary.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 24),

        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;
            if (details.primaryVelocity! > 0) {
              // Swipe right -> Previous
              if (_currentFlashcardIndex > 0) {
                setState(() {
                  _currentFlashcardIndex--;
                });
              }
            } else if (details.primaryVelocity! < 0) {
              // Swipe left -> Next
              if (_currentFlashcardIndex <
                  widget.lesson.vocabulary.length - 1) {
                setState(() {
                  _currentFlashcardIndex++;
                });
              }
            }
          },
          onTap: () {
            setState(() {
              _flippedCards[_currentFlashcardIndex] = !isFlipped;
            });
            AudioService.instance.speakKannada(word.kannada);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isFlipped
                  ? AppTheme.primaryBlue.withOpacity(0.08)
                  : (isDark ? AppTheme.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isFlipped
                    ? AppTheme.primaryBlue
                    : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                width: 2.5,
              ),
              boxShadow: AppTheme.premiumShadow(isDark: isDark),
            ),
            alignment: Alignment.center,
            child: isFlipped
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.english,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: AppTheme.primaryBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pronounced: "${word.pronunciation}"',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tap to hear pronunciation',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryBlue.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.kannada,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to reveal English (Swipe to navigate)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: _currentFlashcardIndex > 0
                  ? () {
                      setState(() {
                        _currentFlashcardIndex--;
                      });
                    }
                  : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                side: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed:
                  _currentFlashcardIndex < widget.lesson.vocabulary.length - 1
                  ? () {
                      setState(() {
                        _currentFlashcardIndex++;
                      });
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              label: const Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                side: BorderSide(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
