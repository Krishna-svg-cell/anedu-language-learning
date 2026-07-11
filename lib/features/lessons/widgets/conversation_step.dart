import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/widgets/mittu_companion_header.dart';
import '../../../../core/widgets/mittu_widget.dart';
import '../../../../core/widgets/typing_indicator.dart';
import '../../../../core/database/local_db.dart';
import '../../../../models/lesson.dart';

class ConversationStep extends StatefulWidget {
  final Lesson lesson;
  final Function(bool) onCompleted;
  final bool isRoleplay;

  const ConversationStep({
    super.key,
    required this.lesson,
    required this.onCompleted,
    this.isRoleplay = true,
  });

  @override
  State<ConversationStep> createState() => _ConversationStepState();
}

class _ConversationStepState extends State<ConversationStep> {
  int _visibleTurns = 1;
  bool _isSpeakingConversationTurn = false;
  String? _conversationFeedback;
  bool _isFeedbackSuccess = false;
  String _liveSpokenText = '';
  bool _isTyping = false;

  String _generatePronunciationTip(String expectedKannada, String expectedPron, String actualSpoken) {
    final expectedWords = expectedKannada.split(RegExp(r'\s+'));
    final pronWords = expectedPron.split(RegExp(r'\s+'));
    final actualWords = actualSpoken.split(RegExp(r'\s+'));
    
    final missingPronunciations = <String>[];
    
    for (int i = 0; i < expectedWords.length; i++) {
      final expectedWord = expectedWords[i].replaceAll(RegExp(r'[^\u0C80-\u0CFF]'), '');
      if (expectedWord.isEmpty) continue;
      
      bool found = false;
      for (final actualWord in actualWords) {
        final normalizedActual = actualWord.replaceAll(RegExp(r'[^\u0C80-\u0CFF]'), '');
        if (normalizedActual.contains(expectedWord) || expectedWord.contains(normalizedActual)) {
          found = true;
          break;
        }
      }
      
      if (!found && i < pronWords.length) {
        missingPronunciations.add(pronWords[i]);
      }
    }
    
    if (missingPronunciations.isNotEmpty) {
      return "Focus on the pronunciation of: '${missingPronunciations.join(', ')}'";
    }
    return "Keep practicing for clearer articulation!";
  }

  @override
  void initState() {
    super.initState();
    _visibleTurns = 1;
    if (widget.lesson.dialogue.isNotEmpty) {
      final firstTurn = widget.lesson.dialogue.first;
      if (!firstTurn.isUser) {
        _showAiTurn(0);
      } else {
        if (widget.lesson.dialogue.length == 1) {
          widget.onCompleted(true);
        }
      }
    } else {
      widget.onCompleted(true);
    }
  }

  void _showAiTurn(int index) {
    if (index >= widget.lesson.dialogue.length) return;
    setState(() {
      _isTyping = true;
      _conversationFeedback = null;
    });
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _visibleTurns = index + 1;
        });
        final turn = widget.lesson.dialogue[index];
        AudioService.instance.speakKannada(turn.textKannada);
        
        // Handle consecutive AI dialogue cards automatically with dynamic pacing based on text length
        if (_visibleTurns < widget.lesson.dialogue.length) {
          final nextTurn = widget.lesson.dialogue[_visibleTurns];
          if (!nextTurn.isUser) {
            // Dynamic delay: roughly 85ms per character, min 2500ms, max 8000ms
            final int delayMs = (turn.textKannada.length * 85).clamp(2500, 8000);
            Timer(Duration(milliseconds: delayMs), () {
              if (mounted) {
                _showAiTurn(_visibleTurns);
              }
            });
            return;
          }
        }
        
        if (_visibleTurns == widget.lesson.dialogue.length && !turn.isUser) {
          widget.onCompleted(true);
        }
      }
    });
  }


  @override
  void dispose() {
    AudioService.instance.stopListening();
    super.dispose();
  }

  Future<void> _recordResponse(String expected) async {
    setState(() {
        _isSpeakingConversationTurn = true;
        _conversationFeedback = null;
        _liveSpokenText = '';
      });

      try {
        final available = await AudioService.instance.initSpeech();
        if (!available) {
          // Fallback if mic not available
          await AudioService.instance.speakKannada(expected);
          await Future.delayed(const Duration(milliseconds: 1500));
          if (!mounted) return;
          setState(() {
            _isSpeakingConversationTurn = false;
            _conversationFeedback = null;
            if (_visibleTurns < widget.lesson.dialogue.length) {
              _visibleTurns++;
              if (_visibleTurns < widget.lesson.dialogue.length) {
                final nextTurn = widget.lesson.dialogue[_visibleTurns];
                if (!nextTurn.isUser) {
                  _showAiTurn(_visibleTurns);
                }
              } else {
                widget.onCompleted(true);
              }
            } else {
              widget.onCompleted(true);
            }
          });
          AudioService.instance.playCorrect();
          return;
        }

        await AudioService.instance.startListening(
          onResult: (text, isFinal) {
            if (!mounted) return;
            
            setState(() {
              _liveSpokenText = text;
            });

            if (isFinal && text.trim().isNotEmpty) {
              LocalDb.setLastPronunciationDate(DateTime.now());
              
              final currentTurn = widget.lesson.dialogue[_visibleTurns];
              final simKannada = AudioService.instance.calculateSimilarity(
                currentTurn.textKannada,
                text,
              );
              final simPron = AudioService.instance.calculateSimilarity(
                currentTurn.pronunciation,
                text,
              );
              final simEng = AudioService.instance.calculateSimilarity(
                currentTurn.textEnglish,
                text,
              );

              // Take the best matching score
              final double similarity = [simKannada, simPron, simEng]
                  .reduce((curr, next) => curr > next ? curr : next);

              final double finalSimilarity = similarity;
              final score = (finalSimilarity * 100).round();

              setState(() {
                _isSpeakingConversationTurn = false;
                if (finalSimilarity >= 0.50) {
                  _isFeedbackSuccess = true;
                  _conversationFeedback = "Excellent! Match: $score% 🌟";
                  
                  Timer(const Duration(milliseconds: 1600), () {
                    if (mounted) {
                      setState(() {
                        _conversationFeedback = null;
                        if (_visibleTurns < widget.lesson.dialogue.length) {
                          _visibleTurns++;
                          if (_visibleTurns < widget.lesson.dialogue.length) {
                            final nextTurn = widget.lesson.dialogue[_visibleTurns];
                            if (!nextTurn.isUser) {
                              _showAiTurn(_visibleTurns);
                            }
                          } else {
                            widget.onCompleted(true);
                          }
                        } else {
                          widget.onCompleted(true);
                        }
                      });
                    }
                  });
                  AudioService.instance.playCorrect();
                } else {
                  _isFeedbackSuccess = false;
                  final tip = _generatePronunciationTip(
                    currentTurn.textKannada,
                    currentTurn.pronunciation,
                    text,
                  );
                  _conversationFeedback =
                      "Match: $score%. $tip. Heard: '$text'";
                  AudioService.instance.playIncorrect();
                }
              });

              AudioService.instance.stopListening();
            }
          },
        );

      // Timeout safety (Extended to 12s, does NOT auto-proceed)
      Future.delayed(const Duration(seconds: 12), () {
        if (mounted && _isSpeakingConversationTurn) {
          setState(() {
            _isSpeakingConversationTurn = false;
            _conversationFeedback = "Silence detected. Please tap to try speaking again! 🎙️🐘";
          });
          AudioService.instance.playIncorrect();
          AudioService.instance.stopListening();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSpeakingConversationTurn = false;
          _conversationFeedback = "Error recording microphone. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MittuCompanionHeader(
          message: widget.isRoleplay
              ? "AI Roleplay Mode: Tap the mic and read your response aloud to practice speaking Kannada! 🎙️🐘💬"
              : "Listening Mode: Listen to this conversation in Karnataka. Tap dialogue boxes to replay native audio! 🎧🐘💬",
          mood: MittuMood.happy,
          size: 90,
        ),
        const SizedBox(height: 12),

        // Chat bubble lists
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _visibleTurns.clamp(0, widget.lesson.dialogue.length),
          itemBuilder: (context, index) {
            final turn = widget.lesson.dialogue[index];
            final isUser = turn.isUser;

            return TweenAnimationBuilder<double>(
              key: ValueKey('msg_${turn.textKannada}_$index'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Transform.translate(
                  offset: Offset(0.0, 15.0 * (1.0 - val)),
                  child: Opacity(
                    opacity: val,
                    child: child,
                  ),
                );
              },
              child: Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.primaryBlue
                        : (isDark ? AppTheme.darkCard : Colors.white),
                    border: Border.all(
                      color: isUser
                          ? AppTheme.primaryBlue
                          : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser
                          ? const Radius.circular(20)
                          : Radius.zero,
                      bottomRight: isUser
                          ? Radius.zero
                          : const Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            turn.speaker,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isUser
                                  ? Colors.white70
                                  : AppTheme.primaryBlue,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.volume_up_rounded,
                              color: isUser
                                  ? Colors.white70
                                  : AppTheme.primaryBlue,
                              size: 16,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              AudioService.instance.speakKannada(
                                turn.textKannada,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        turn.textKannada,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isUser
                              ? Colors.white
                              : (isDark
                                    ? Colors.white
                                    : AppTheme.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"${turn.pronunciation}"',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: isUser ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const Divider(height: 12, color: Colors.white24),
                      Text(
                        turn.textEnglish,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUser
                              ? Colors.white.withOpacity(0.9)
                              : (isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),


        // Feedback alert banner for speaking
        if (_conversationFeedback != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isFeedbackSuccess
                  ? AppTheme.successGreen.withOpacity(0.08)
                  : AppTheme.errorRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFeedbackSuccess
                    ? AppTheme.successGreen.withOpacity(0.3)
                    : AppTheme.errorRed.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isFeedbackSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  color: _isFeedbackSuccess ? AppTheme.successGreen : AppTheme.errorRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _conversationFeedback!,
                    style: TextStyle(
                      color: _isFeedbackSuccess ? AppTheme.successGreen : AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Typing indicator
        if (_isTyping) ...[
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: TypingIndicator(),
            ),
          ),
        ],

        // Interactive "Speak" / "Continue Chat" triggers
        if (_visibleTurns < widget.lesson.dialogue.length && !_isTyping) ...[
          Builder(
            builder: (context) {
              final nextTurn = widget.lesson.dialogue[_visibleTurns];
              if (nextTurn.isUser) {
                // If not in roleplay mode, do not show microphone controls. Simply let them tap to read/hear.
                if (!widget.isRoleplay) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            width: 1.5,
                          ),
                          boxShadow: AppTheme.premiumShadow(isDark: isDark),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Your Turn (Listen & Learn):",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nextTurn.textKannada,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Pronunciation: \"${nextTurn.pronunciation}\"",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.secondaryOrange,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Meaning: \"${nextTurn.textEnglish}\"",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _visibleTurns++;
                            AudioService.instance.speakKannada(nextTurn.textKannada);
                            if (_visibleTurns < widget.lesson.dialogue.length) {
                              final futureTurn = widget.lesson.dialogue[_visibleTurns];
                              if (!futureTurn.isUser) {
                                _showAiTurn(_visibleTurns);
                              }
                            } else {
                              widget.onCompleted(true);
                            }
                          });
                        },
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Next Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // AI Roleplay Mode with active microphone capture
                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          width: 1.5,
                        ),
                        boxShadow: AppTheme.premiumShadow(isDark: isDark),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Speak this in Kannada:",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            nextTurn.textKannada,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Pronunciation: \"${nextTurn.pronunciation}\"",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.secondaryOrange,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Meaning: \"${nextTurn.textEnglish}\"",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isSpeakingConversationTurn) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Column(
                          children: [
                            const _PulsingMicButton(isRecording: true),
                            const SizedBox(height: 8),
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                              ),
                              child: Text(
                                _liveSpokenText.isEmpty ? 'Listening... Speak now!' : 'Heard: "$_liveSpokenText"',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                  fontStyle: _liveSpokenText.isEmpty ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _recordResponse(nextTurn.textKannada),
                            icon: const Icon(Icons.mic_rounded),
                            label: const Text('Tap to speak'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _conversationFeedback = null;
                                if (_visibleTurns < widget.lesson.dialogue.length) {
                                  _visibleTurns++;
                                  if (_visibleTurns < widget.lesson.dialogue.length) {
                                    final nextT = widget.lesson.dialogue[_visibleTurns];
                                    if (!nextT.isUser) {
                                      _showAiTurn(_visibleTurns);
                                    }
                                  } else {
                                    widget.onCompleted(true);
                                  }
                                } else {
                                  widget.onCompleted(true);
                                }
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Can't talk now"),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              } else {
                return OutlinedButton.icon(
                  onPressed: () => _showAiTurn(_visibleTurns),
                  icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                  label: const Text('Continue Chat'),
                );
              }
            },
          ),
        ],
      ],
    );
  }
}

class _PulsingMicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback? onPressed;

  const _PulsingMicButton({
    required this.isRecording,
    this.onPressed,
  });

  @override
  State<_PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<_PulsingMicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isRecording) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.isRecording)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 36 + (_controller.value * 28),
                height: 36 + (_controller.value * 28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.errorRed.withOpacity(
                    0.3 * (1 - _controller.value),
                  ),
                ),
              );
            },
          ),
        IconButton(
          icon: Icon(
            widget.isRecording ? Icons.mic_rounded : Icons.mic_rounded,
            color: widget.isRecording
                ? AppTheme.errorRed
                : AppTheme.secondaryOrange,
            size: 32,
          ),
          onPressed: widget.onPressed,
        ),
      ],
    );
  }
}
