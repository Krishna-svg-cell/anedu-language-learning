import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/mittu_companion_header.dart';
import '../../../../core/widgets/mittu_widget.dart';
import '../../../../models/lesson.dart';

class MatchStep extends StatefulWidget {
  final Lesson lesson;
  final Function(bool) onMatchedChanged;

  const MatchStep({
    super.key,
    required this.lesson,
    required this.onMatchedChanged,
  });

  @override
  State<MatchStep> createState() => _MatchStepState();
}

class _MatchChipModel {
  final String text;
  final String vocabId;
  final bool isKannada;

  _MatchChipModel({
    required this.text,
    required this.vocabId,
    required this.isKannada,
  });
}

class _MatchStepState extends State<MatchStep> {
  List<_MatchChipModel> _matchChips = [];
  int? _selectedFirstIndex;
  final Set<int> _matchedIndices = {};

  int? _wrongMatchIndex1;
  int? _wrongMatchIndex2;

  @override
  void initState() {
    super.initState();
    // Setup Match Game Chips (Shuffle English and Kannada)
    final List<_MatchChipModel> chips = [];
    for (final w in widget.lesson.vocabulary) {
      chips.add(_MatchChipModel(text: w.kannada, vocabId: w.id, isKannada: true));
      chips.add(_MatchChipModel(text: w.english, vocabId: w.id, isKannada: false));
    }
    _matchChips = chips..shuffle();
  }

  void _handleMatchChipTap(int index) {
    if (_selectedFirstIndex == null) {
      setState(() {
        _selectedFirstIndex = index;
      });
    } else {
      if (_selectedFirstIndex == index) {
        setState(() {
          _selectedFirstIndex = null;
        });
        return;
      }

      final chip1 = _matchChips[_selectedFirstIndex!];
      final chip2 = _matchChips[index];

      // Match condition: same vocabulary word, but different languages
      if (chip1.vocabId == chip2.vocabId && chip1.isKannada != chip2.isKannada) {
        AudioService.instance.playCorrect();
        final firstIdx = _selectedFirstIndex!;
        setState(() {
          _matchedIndices.add(firstIdx);
          _matchedIndices.add(index);
          _selectedFirstIndex = null;
        });
        final allMatched = _matchedIndices.length == _matchChips.length;
        widget.onMatchedChanged(allMatched);
      } else {
        final wrongIndex1 = _selectedFirstIndex;
        final wrongIndex2 = index;
        AudioService.instance.playIncorrect();
        setState(() {
          _wrongMatchIndex1 = wrongIndex1;
          _wrongMatchIndex2 = wrongIndex2;
          _selectedFirstIndex = null;
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              if (_wrongMatchIndex1 == wrongIndex1) _wrongMatchIndex1 = null;
              if (_wrongMatchIndex2 == wrongIndex2) _wrongMatchIndex2 = null;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        MittuCompanionHeader(
          message: "Match the words",
          mood: MittuMood.happy,
          size: 90,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: _matchChips.length,
          itemBuilder: (context, index) {
            final chip = _matchChips[index];
            final isMatched = _matchedIndices.contains(index);
            final isSelected = _selectedFirstIndex == index;
            final isWrong =
                _wrongMatchIndex1 == index || _wrongMatchIndex2 == index;

            Color borderCol = isDark
                ? AppTheme.darkBorder
                : AppTheme.lightBorder;
            Color bgCol = isDark ? AppTheme.darkCard : Colors.white;
            Color textCol = isDark
                ? AppTheme.darkTextPrimary
                : AppTheme.lightTextPrimary;

            if (isMatched) {
              borderCol = AppTheme.successGreen;
              bgCol = AppTheme.successGreen.withOpacity(0.1);
              textCol = AppTheme.successGreen;
            } else if (isWrong) {
              borderCol = AppTheme.errorRed;
              bgCol = AppTheme.errorRed.withOpacity(0.1);
              textCol = AppTheme.errorRed;
            } else if (isSelected) {
              borderCol = AppTheme.primaryBlue;
              bgCol = AppTheme.primaryBlue.withOpacity(0.1);
              textCol = AppTheme.primaryBlue;
            }

            return InkWell(
              onTap: isMatched || isWrong
                  ? null
                  : () => _handleMatchChipTap(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgCol,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol, width: 2.0),
                ),
                child: Text(
                  chip.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textCol,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
