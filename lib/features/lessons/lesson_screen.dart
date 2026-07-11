import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import '../../core/widgets/confetti_celebration.dart';
import '../../core/widgets/mittu_widget.dart';
import '../../core/widgets/mittu_slide_up_overlay.dart';
import '../../core/widgets/dynamic_scene_illustration.dart';
import '../../core/widgets/animated_pressable.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/local_db.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/lesson.dart';
import '../../core/agents/agent_orchestrator.dart';

// Import all step widgets
import 'widgets/situation_step.dart';
import 'widgets/vocabulary_step.dart';
import 'widgets/match_step.dart';
import 'widgets/flashcards_step.dart';
import 'widgets/sentence_builder_step.dart';
import 'widgets/conversation_step.dart';
import 'widgets/quiz_step.dart';
import 'widgets/mission_step.dart';
import 'widgets/celebration_step.dart';
import 'widgets/warmup_step.dart';
import 'widgets/twist_step.dart';
import 'widgets/reflection_step.dart';
import 'widgets/grammar_bites_step.dart';

class ReviewItem {
  final Lesson lesson;
  final int quizIndex;
  ReviewItem({required this.lesson, required this.quizIndex});
}

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int _currentSequenceIndex = 0;
  bool _isLoadingPersonalized = false;
  String _loadingMessage = 'Mittu is preparing your personalized daily Kannada adventure...';
  final List<ReviewItem> _reviewItems = [];
  final List<int> _coreSequence = [0, 1, 2, 4, 3, 5, 8, 9, 6, 7, 10, 14, 15, 12, 11, 13];
  
  int get _currentStep {
    if (_currentSequenceIndex < _reviewItems.length) {
      return -1; // Sentinel value representing a Spaced Repetition Review Step
    }
    return _coreSequence[_currentSequenceIndex - _reviewItems.length];
  }

  int get _totalStepsCount => _reviewItems.length + _coreSequence.length;
  late Lesson _lesson;
  bool _initialized = false;

  // Callback completion tracking variables
  bool _warmupCompleted = false;
  bool _twistCompleted = false;
  bool _reflectionCompleted = false;
  bool _matchCompleted = false;
  bool _sentenceBuilderCompleted = false;
  bool _conversationCompleted = false;

  int _selectedQuizAnswerIndex = -1;
  bool _quizChecked = false;
  bool _quizAnswerCorrect = false;

  bool _isPerfect = true;

  // Gamification combo streaks and animation triggers
  bool _triggerConfetti = false;
  int _quizComboStreak = 0;
  bool _showComboBadge = false;
  bool _showMittuEncouragement = false;
  String _mittuEncouragementText = '';
  MittuMood _mittuEncouragementMood = MittuMood.happy;
  bool _showFullScreenCelebration = false;
  String _correctAnswerHint = '';

  String _getRandomPraise() {
    final praises = [
      "Amazing job! You're picking this up so fast! 🌟",
      "Correct! Mittu is doing a happy dance! 🐘🎉",
      "Fantastic! Your Kannada is getting super sharp! 💎",
      "Brilliant! Keep going, you're unstoppable! 🔥",
      "Spot on! Mittu is so proud of you! ❤️",
    ];
    return praises[Random().nextInt(praises.length)];
  }

  @override
  void initState() {
    super.initState();
    _loadAgenticLesson();
  }

  void _loadAgenticLesson() async {
    final id = widget.lessonId;
    if (id.startsWith('day_')) {
      final numStr = id.replaceAll('day_', '');
      final parsedDay = int.tryParse(numStr);
      if (parsedDay != null) {
        setState(() {
          _isLoadingPersonalized = true;
          _loadingMessage = 'Mittu is analyzing your goals & skills... 🐘';
        });
        
        await Future.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        
        setState(() {
          _loadingMessage = 'Generating situation vocabulary & dialogue... ✍️';
        });

        try {
          await ref.read(lessonsListProvider.notifier).pregeneratePersonalizedLesson(parsedDay);
        } catch (e) {
          debugPrint("Failed to pregenerate lesson: $e");
        }

        if (!mounted) return;
        setState(() {
          _loadingMessage = 'Safety checking translation accuracy... 🛡️';
        });
        await Future.delayed(const Duration(milliseconds: 450));
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoadingPersonalized = false;
    });
    _initLessonData();
  }

  void _initLessonData() {
    if (_initialized) return;
    final lessons = ref.read(lessonsListProvider);
    _lesson = lessons.firstWhere(
      (l) => l.id == widget.lessonId,
      orElse: () => lessons.first,
    );

    if (!_lesson.isUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔒 This lesson is locked! Complete preceding days or wait for tomorrow\'s unlock.'),
            duration: Duration(seconds: 3),
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/');
        }
      });
      return;
    }

    // Populate review questions from actual mistakes (weak words) first
    final weakList = LocalDb.getWeakWords();
    _reviewItems.clear();
    
    if (weakList.isNotEmpty) {
      final random = Random();
      // Dynamically load up to 3 weak words to revise
      final numReview = min(3, weakList.length);
      final chosenWeak = (List<Map<String, dynamic>>.from(weakList)..shuffle(random)).take(numReview).toList();
      for (final item in chosenWeak) {
        final lId = item['lessonId'] as String;
        final qIdx = item['quizIndex'] as int;
        try {
          final prevLesson = lessons.firstWhere((l) => l.id == lId);
          if (prevLesson.quiz.isNotEmpty && qIdx < prevLesson.quiz.length) {
            _reviewItems.add(ReviewItem(lesson: prevLesson, quizIndex: qIdx));
          }
        } catch (_) {}
      }
    }
    
    // Fallback: if we still have fewer than 2 review items, load random completed questions
    if (_reviewItems.length < 2) {
      final completed = lessons.where((l) => l.isCompleted && l.id != widget.lessonId).toList();
      if (completed.isNotEmpty) {
        final random = Random();
        final needed = 2 - _reviewItems.length;
        final chosenLessons = (List<Lesson>.from(completed)..shuffle(random)).take(min(needed, completed.length)).toList();
        for (final prevLesson in chosenLessons) {
          if (prevLesson.quiz.isNotEmpty) {
            final qIndex = random.nextInt(prevLesson.quiz.length);
            final alreadyPresent = _reviewItems.any((item) => item.lesson.id == prevLesson.id && item.quizIndex == qIndex);
            if (!alreadyPresent) {
              _reviewItems.add(ReviewItem(lesson: prevLesson, quizIndex: qIndex));
            }
          }
        }
      }
    }

    _initialized = true;
  }

  void _nextStep() {
    if (_currentSequenceIndex < _totalStepsCount - 1) {
      setState(() {
        _currentSequenceIndex++;
        // Reset state variables to prevent locks on subsequent steps
        _warmupCompleted = false;
        _twistCompleted = false;
        _reflectionCompleted = false;
        _matchCompleted = false;
        _sentenceBuilderCompleted = false;
        _conversationCompleted = false;
        _selectedQuizAnswerIndex = -1;
        _quizChecked = false;
        _quizAnswerCorrect = false;
        _quizComboStreak = 0;
        _showComboBadge = false;
        _showMittuEncouragement = false;
        _correctAnswerHint = '';
      });
      if (_currentStep == 12) {
        AudioService.instance.playSuccess();
      }
    } else {
      AudioService.instance.playMissionComplete();
      _showFeedbackAndExit();
    }
  }

  void _showFeedbackAndExit() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    double localConfidence = ref.read(userProgressProvider).currentConfidence.toDouble();
    String wasUseful = 'Yes';
    String usedOutside = 'Tried once';
    String difficultyCorrect = 'Just Right';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: MittuWidget(
                    mood: MittuMood.happy,
                    size: 80,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Daily Mission Complete! 🌟',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help Mittu measure your learning outcome. How was your experience today?',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Question 1: Was this useful?
                const Text(
                  '1. Was this situation useful for your life?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: ['Yes', 'Somewhat', 'No'].map((opt) {
                    final isSelected = wasUseful == opt;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: OutlinedButton(
                          onPressed: () => setModalState(() => wasUseful = opt),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected ? AppTheme.primaryBlue.withOpacity(0.15) : Colors.transparent,
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                            ),
                          ),
                          child: Text(opt),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Question 2: Did you use outside?
                const Text(
                  '2. Did you use this Kannada outside today?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: ['Tried once', 'Multiple times', 'Not yet'].map((opt) {
                    final isSelected = usedOutside == opt;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: OutlinedButton(
                          onPressed: () => setModalState(() => usedOutside = opt),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected ? AppTheme.primaryBlue.withOpacity(0.15) : Colors.transparent,
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                            ),
                          ),
                          child: Text(opt, style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Question 3: Difficulty correct?
                const Text(
                  '3. Was the lesson difficulty level correct?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: ['Too Easy', 'Just Right', 'Too Hard'].map((opt) {
                    final isSelected = difficultyCorrect == opt;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: OutlinedButton(
                          onPressed: () => setModalState(() => difficultyCorrect = opt),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isSelected ? AppTheme.primaryBlue.withOpacity(0.15) : Colors.transparent,
                            side: BorderSide(
                              color: isSelected ? AppTheme.primaryBlue : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                            ),
                          ),
                          child: Text(opt),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Question 4: Speaking Confidence update
                Text(
                  '4. Rate your current speaking confidence: ${localConfidence.round()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: localConfidence,
                  min: 10.0,
                  max: 100.0,
                  divisions: 9,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (val) {
                    setModalState(() {
                      localConfidence = val;
                    });
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    // Update current confidence & save feedback to analytics log
                    final currentProg = ref.read(userProgressProvider);
                    final updatedConfidence = localConfidence.round();

                    ref.read(userProgressProvider.notifier).updateProgress(
                      currentProg.copyWith(
                        currentConfidence: updatedConfidence,
                      ),
                    );

                    // Complete lesson
                    ref.read(lessonsListProvider.notifier).completeLesson(_lesson.id, isPerfect: _isPerfect);

                    Navigator.pop(context); // Close sheet
                    Navigator.pop(context); // Close lesson screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save & Finish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _canProceed() {
    if (_currentSequenceIndex < _reviewItems.length) {
      return true; // Control handled via explicit button checkers
    }
    if (_currentStep == 2) {
      return _warmupCompleted;
    }
    if (_currentStep == 3) {
      return _conversationCompleted;
    }
    if (_currentStep == 6) {
      return true; // Auto-enabled via step callback to prevent locking
    }
    if (_currentStep == 7) {
      return _conversationCompleted;
    }
    if (_currentStep == 8) {
      return _twistCompleted;
    }
    if (_currentStep == 9) {
      return true; // Allow proceeding on matching activity at any time
    }
    if (_currentStep == 10) {
      return true; // Bottom action custom checkers control quiz
    }
    if (_currentStep == 13) {
      return _reflectionCompleted;
    }
    return true;
  }

  void _nextPageAction() {
    if (_currentSequenceIndex < _reviewItems.length || _currentStep == 10 || _currentStep == 14 || _currentStep == 15) {
      setState(() {
        _quizChecked = false;
        _selectedQuizAnswerIndex = -1;
      });
    }
    _nextStep();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPersonalized) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MittuWidget(
                mood: MittuMood.reading,
                size: 140,
                animate: true,
              ),
              const SizedBox(height: 28),
              Text(
                'Personalizing Daily Adventure',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  _loadingMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ],
          ),
        ),
      );
    }

    _initLessonData();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final double contentWidth = (screenHeight * 9 / 16).clamp(320.0, 480.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            AudioService.instance.playPop();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Quit Lesson?'),
                content: const Text(
                  'You will lose progress on this lesson if you exit now.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      AudioService.instance.playClick();
                      Navigator.pop(context);
                    },
                    child: const Text('Keep Learning'),
                  ),
                  TextButton(
                    onPressed: () {
                      AudioService.instance.playClick();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Quit',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: (_currentSequenceIndex + 1) / _totalStepsCount,
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                color: AppTheme.primaryBlue,
                minHeight: 10,
              );
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '${_currentSequenceIndex + 1}/$_totalStepsCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.06, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: SingleChildScrollView(
                            key: ValueKey<int>(_currentSequenceIndex),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_currentStep != -1 && _currentStep != 0 && _currentStep != 11 && _currentStep != 12)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: DynamicSceneIllustration(
                                      imagePath: _lesson.illustrationPath,
                                      stepIndex: _currentStep,
                                      height: 110.0,
                                      disableNight: true,
                                    ),
                                  ),
                                _buildStepContent(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildBottomAction(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ConfettiCelebration(trigger: _triggerConfetti),
          ),
          if (_showComboBadge)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, val, child) {
                    return Transform.scale(
                      scale: val,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentYellow.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🔥',
                              style: TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'COMBO x$_quizComboStreak!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (_showMittuEncouragement)
            Positioned(
              bottom: 110,
              right: 0,
              left: 0,
              child: MittuSlideUpOverlay(
                visible: _showMittuEncouragement,
                message: _mittuEncouragementText,
                mood: MittuMood.happy,
                onDismiss: () {
                  setState(() {
                    _showMittuEncouragement = false;
                  });
                },
              ),
            ),
          if (_showFullScreenCelebration)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: contentWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _quizAnswerCorrect
                                ? (isDark
                                    ? [const Color(0xE614321A), const Color(0xE60F2513)]
                                    : [const Color(0xE6E8F5E9), const Color(0xE6C8E6C9)])
                                : (isDark
                                    ? [const Color(0xE63E1217), const Color(0xE62C0B0F)]
                                    : [const Color(0xE6FFEBEE), const Color(0xE6FFCDD2)]),
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          border: Border.all(
                            color: _quizAnswerCorrect
                                ? AppTheme.successGreen.withOpacity(0.5)
                                : AppTheme.errorRed.withOpacity(0.5),
                            width: 2.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(height: 20),
                            // Title Header
                            Column(
                              children: [
                                Text(
                                  _quizAnswerCorrect ? '🎉 EXCELLENT!' : '❌ STUDY HINT',
                                  style: TextStyle(
                                    color: _quizAnswerCorrect
                                        ? AppTheme.successGreen
                                        : AppTheme.errorRed,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _quizAnswerCorrect ? 'You got it right!' : 'Take a moment to review',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Mascot spring pop-out animation
                            TweenAnimationBuilder<double>(
                              key: ValueKey('mittu_overlay_${_currentSequenceIndex}_$_quizAnswerCorrect'),
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.elasticOut,
                              builder: (context, scaleVal, child) {
                                return Transform.scale(
                                  scale: scaleVal,
                                  child: MittuWidget(
                                    mood: _quizAnswerCorrect
                                        ? MittuMood.happy
                                        : MittuMood.sad,
                                    size: 200,
                                    animate: true,
                                  ),
                                );
                              },
                            ),
                            
                            // Explanation message
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.black26 : Colors.white60),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (isDark ? Colors.white10 : Colors.black12),
                                ),
                              ),
                              child: Text(
                                _quizAnswerCorrect
                                    ? (_mittuEncouragementText.isNotEmpty
                                        ? _mittuEncouragementText
                                        : 'Sakkath! That is correct! 🐘🌟')
                                    : (_correctAnswerHint.isNotEmpty
                                        ? 'Correct Answer:\n"$_correctAnswerHint"'
                                        : 'No worries! Keep practicing with Mittu! 💪'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            
                            // Continue / Got It button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _showFullScreenCelebration = false;
                                  });
                                  _nextPageAction();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _quizAnswerCorrect
                                      ? AppTheme.successGreen
                                      : AppTheme.errorRed,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shadowColor: (_quizAnswerCorrect
                                      ? AppTheme.successGreen.withOpacity(0.4)
                                      : AppTheme.errorRed.withOpacity(0.4)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  _quizAnswerCorrect ? 'Continue' : 'Got It',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    if (_currentSequenceIndex < _reviewItems.length) {
      final review = _reviewItems[_currentSequenceIndex];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.secondaryOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🔄 Spaced Repetition Revision',
              style: TextStyle(
                color: AppTheme.secondaryOrange,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          QuizStep(
            key: ValueKey('review_${review.lesson.id}_${review.quizIndex}'),
            lesson: review.lesson,
            currentQuizQuestionIndex: review.quizIndex,
            selectedQuizAnswerIndex: _selectedQuizAnswerIndex,
            quizChecked: _quizChecked,
            onOptionSelected: (idx) {
              setState(() {
                _selectedQuizAnswerIndex = idx;
              });
            },
            comboStreak: _quizComboStreak,
          ),
        ],
      );
    }

    switch (_currentStep) {
      case 0:
        // Story Introduction Storyboard
        return SituationStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onCompleted: _nextPageAction,
        );
      case 1:
        // Grammar Bites Overview
        return GrammarBitesStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
        );
      case 2:
        // AI Warm-up Question
        return WarmUpQuestionStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onCompleted: (isCompleted) {
            setState(() {
              _warmupCompleted = isCompleted;
            });
          },
          onAnswered: (isCorrect) {
            if (isCorrect) {
              setState(() {
                _triggerConfetti = !_triggerConfetti;
                _mittuEncouragementText = "Sakkath! That is correct! 🌟";
                _quizAnswerCorrect = true;
                _showFullScreenCelebration = true;
              });
            }
          },
        );
      case 3:
        // Real Conversation
        return ConversationStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onCompleted: (isCompleted) {
            setState(() {
              _conversationCompleted = isCompleted;
            });
          },
          isRoleplay: false,
        );
      case 4:
        // Vocabulary in Context
        return VocabularyStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
        );
      case 5:
        // Pronunciation Practice
        return FlashcardsStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
        );
      case 6:
        // Sentence Builder
        return SentenceBuilderStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onSentenceChanged: (isCorrect) {
            setState(() {
              _sentenceBuilderCompleted = isCorrect;
              if (isCorrect) {
                _triggerConfetti = !_triggerConfetti;
                _mittuEncouragementText = "Brilliant! Sentence completed! 🌟";
                _quizAnswerCorrect = true;
                _showFullScreenCelebration = true;
              }
            });
          },
        );
      case 7:
        // AI Roleplay
        return ConversationStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onCompleted: (isCompleted) {
            setState(() {
              _conversationCompleted = isCompleted;
            });
          },
          isRoleplay: true,
        );
      case 8:
        // Situation Twist
        return SituationTwistStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onCompleted: (isCompleted) {
            setState(() {
              _twistCompleted = isCompleted;
            });
          },
        );
      case 9:
        // Mini Game
        return MatchStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onMatchedChanged: (isCompleted) {
            setState(() {
              _matchCompleted = isCompleted;
            });
          },
        );
      case 10:
        // Final Challenge - Question 1
        return QuizStep(
          key: const ValueKey(10),
          lesson: _lesson,
          currentQuizQuestionIndex: 1,
          selectedQuizAnswerIndex: _selectedQuizAnswerIndex,
          quizChecked: _quizChecked,
          onOptionSelected: (idx) {
            setState(() {
              _selectedQuizAnswerIndex = idx;
            });
          },
          comboStreak: _quizComboStreak,
        );
      case 14:
        // Final Challenge - Question 2
        return QuizStep(
          key: const ValueKey(14),
          lesson: _lesson,
          currentQuizQuestionIndex: 2,
          selectedQuizAnswerIndex: _selectedQuizAnswerIndex,
          quizChecked: _quizChecked,
          onOptionSelected: (idx) {
            setState(() {
              _selectedQuizAnswerIndex = idx;
            });
          },
          comboStreak: _quizComboStreak,
        );
      case 15:
        // Final Challenge - Question 3
        return QuizStep(
          key: const ValueKey(15),
          lesson: _lesson,
          currentQuizQuestionIndex: 3,
          selectedQuizAnswerIndex: _selectedQuizAnswerIndex,
          quizChecked: _quizChecked,
          onOptionSelected: (idx) {
            setState(() {
              _selectedQuizAnswerIndex = idx;
            });
          },
          comboStreak: _quizComboStreak,
        );
      case 11:
        // Mission Summary
        return MissionStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
        );
      case 12:
        // Rewards (Celebration)
        return CelebrationStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
        );
      case 13:
        // Reflection
        return ReflectionStep(
          key: ValueKey(_currentStep),
          lesson: _lesson,
          onCompleted: (isCompleted) {
            setState(() {
              _reflectionCompleted = isCompleted;
            });
          },
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomAction(bool isDark) {
    if (_showFullScreenCelebration) {
      return const SizedBox.shrink();
    }

    // Checking mechanism for Spaced Repetition Review quizzes
    if (_currentSequenceIndex < _reviewItems.length) {
      final review = _reviewItems[_currentSequenceIndex];
      final quiz = review.lesson.quiz[review.quizIndex.clamp(0, review.lesson.quiz.length - 1)];

      if (!_quizChecked) {
        return SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedQuizAnswerIndex == -1
                ? null
                : () {
                    final selectedVal = quiz.options[_selectedQuizAnswerIndex];
                    final cleanSelect = selectedVal.trim().toLowerCase();
                    final cleanCorrect = (quiz.correctAnswer ?? '').trim().toLowerCase();
                    setState(() {
                      _quizChecked = true;
                      _quizAnswerCorrect = cleanSelect == cleanCorrect;
                    });
                    if (_quizAnswerCorrect) {
                      AudioService.instance.playCorrect();
                      LocalDb.removeWeakWord(review.lesson.id, review.quizIndex);
                      setState(() {
                        _quizComboStreak++;
                        _triggerConfetti = !_triggerConfetti;
                        _mittuEncouragementText = "Excellent! Previous day review verified! 🧠🌟";
                        _showFullScreenCelebration = true;
                      });
                    } else {
                      AudioService.instance.playIncorrect();
                      LocalDb.addWeakWord(review.lesson.id, review.quizIndex);
                      setState(() {
                        _quizComboStreak = 0;
                        _correctAnswerHint = quiz.correctAnswer ?? '';
                        _showFullScreenCelebration = true;
                      });
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              disabledForegroundColor: Colors.grey[500],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Check Answer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextPageAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        );
      }
    }

    if (_currentStep == 0) {
      return SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: _nextPageAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start Mission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      );
    }
    if (_currentStep == 10 || _currentStep == 14 || _currentStep == 15) {
      final int qIndex = _currentStep == 10 ? 1 : (_currentStep == 14 ? 2 : 3);
      if (!_quizChecked) {
        return SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedQuizAnswerIndex == -1
                ? null
                : () {
                    final quiz = _lesson.quiz[qIndex];
                    final selectedVal = quiz.options[_selectedQuizAnswerIndex];
                    final cleanSelect = selectedVal.trim().toLowerCase();
                    final cleanCorrect = (quiz.correctAnswer ?? '').trim().toLowerCase();
                    setState(() {
                      _quizChecked = true;
                      _quizAnswerCorrect = cleanSelect == cleanCorrect;
                    });
                    if (_quizAnswerCorrect) {
                      AudioService.instance.playCorrect();
                      LocalDb.removeWeakWord(_lesson.id, qIndex);
                      ref.read(userProgressProvider.notifier).recordQuizCompleted();
                      setState(() {
                        _quizComboStreak++;
                        if (_quizComboStreak >= 2) {
                          _showComboBadge = true;
                          AudioService.instance.playStreak();
                        }
                        _triggerConfetti = !_triggerConfetti;
                        _mittuEncouragementText = _getRandomPraise();
                        _correctAnswerHint = '';
                        _showFullScreenCelebration = true;
                      });
                    } else {
                      AudioService.instance.playIncorrect();
                      LocalDb.addWeakWord(_lesson.id, qIndex);
                      setState(() {
                        _isPerfect = false;
                        _quizComboStreak = 0;
                        _showComboBadge = false;
                        _correctAnswerHint = quiz.correctAnswer ?? '';
                        _showFullScreenCelebration = true;
                      });
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              disabledForegroundColor: Colors.grey[500],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Check Answer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        );
      } else {
        return SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextPageAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        );
      }
    }

    final bool enabled = _canProceed();

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _nextPageAction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          disabledForegroundColor: Colors.grey[500],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          _currentStep == 12 ? 'Finish & Claim' : 'Continue',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
