import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/mittu_companion_header.dart';
import '../../../../core/widgets/mittu_widget.dart';
import '../../../../models/lesson.dart';

class SentenceBuilderStep extends StatefulWidget {
  final Lesson lesson;
  final Function(bool) onSentenceChanged;

  const SentenceBuilderStep({
    super.key,
    required this.lesson,
    required this.onSentenceChanged,
  });

  @override
  State<SentenceBuilderStep> createState() => _SentenceBuilderStepState();
}

class _SentenceBuilderStepState extends State<SentenceBuilderStep> {
  final List<String> _assembledSentence = [];
  List<String> _remainingSentenceChips = [];

  @override
  void initState() {
    super.initState();
    _remainingSentenceChips = List<String>.from(
      widget.lesson.sentenceBuilderWords,
    )..shuffle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSentenceChanged(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final combined = _assembledSentence.join(' ');
    final isCorrect = combined == widget.lesson.sentenceBuilderAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MittuCompanionHeader(
          message: widget.lesson.sentenceBuilderTranslation,
          mood: MittuMood.happy,
          size: 90,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        // Display assembled words with dashed placeholder effect
        Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard
                : Colors.grey[500]!.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCorrect
                  ? AppTheme.successGreen
                  : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
              width: 2.0,
            ),
          ),
          child: _assembledSentence.isEmpty
              ? const Center(
                  child: Text(
                    'Tap chips below to build...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _assembledSentence.map((word) {
                    return InputChip(
                      label: Text(
                        word,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                      deleteIconColor: AppTheme.primaryBlue,
                      onDeleted: () {
                        setState(() {
                          _assembledSentence.remove(word);
                          _remainingSentenceChips.add(word);
                        });
                        final combined = _assembledSentence.join(' ').trim().toLowerCase();
                        final expected = (widget.lesson.sentenceBuilderAnswer ?? '').trim().toLowerCase();
                        widget.onSentenceChanged(combined == expected);
                      },
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 24),

        // Remaining selection chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _remainingSentenceChips.map((chip) {
            return ActionChip(
              label: Text(
                chip,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
              side: BorderSide(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              onPressed: () {
                setState(() {
                  _remainingSentenceChips.remove(chip);
                  _assembledSentence.add(chip);
                });

                final nextCombined = _assembledSentence.join(' ').trim().toLowerCase();
                final expected = (widget.lesson.sentenceBuilderAnswer ?? '').trim().toLowerCase();
                widget.onSentenceChanged(nextCombined == expected);

                if (nextCombined == expected) {
                  AudioService.instance.speakKannada(
                    widget.lesson.sentenceBuilderAnswer ?? '',
                  );
                }
              },
            );
          }).toList(),
        ),

        if (isCorrect) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.successGreen.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.successGreen,
                  size: 24,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Perfect match! Auto-narrating sentence...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successGreen,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppTheme.successGreen,
                  ),
                  onPressed: () {
                    AudioService.instance.speakKannada(
                      widget.lesson.sentenceBuilderAnswer,
                    );
                  },
                ),
              ],
            ),
          ),
        ] else if (_assembledSentence.isNotEmpty && _remainingSentenceChips.isEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.errorRed.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.errorRed,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Not quite right, but you can proceed!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorRed,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Correct Order: "${widget.lesson.sentenceBuilderAnswer}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
