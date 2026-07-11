import 'agent_state.dart';
import 'model_router.dart';

class TutorPersonaProfile {
  final String styleName; // "Slow & Friendly", "Challenging & Fast", "Encouraging", "Competitive"
  final String instructionGuideline;
  final String feedbackStyle;
  final double xpRewardMultiplier;

  TutorPersonaProfile({
    required this.styleName,
    required this.instructionGuideline,
    required this.feedbackStyle,
    required this.xpRewardMultiplier,
  });
}

class TutorPersonaAgent {
  static final TutorPersonaAgent instance = TutorPersonaAgent._internal();
  TutorPersonaAgent._internal();

  Future<AgentState> process(AgentState state) async {
    final progress = state.userProfile;
    final lessonsCount = progress.lessonsCompletedCount;
    final quizzesCount = progress.quizzesCompletedCount;
    final coins = progress.coins;

    // Define System Instruction
    const String systemInstruction = '''
You are the TutorPersonaAgent in an Agentic AI Kannada learning app.
Analyze the user's progress statistics and learning style.
Return a structured JSON reasoning payload matching this schema:
{
  "styleName": "Slow & Friendly | Challenging & Fast | Encouraging & Practical | Balanced & Competitive",
  "instructionGuideline": "Specific guidelines for lesson content generator",
  "feedbackStyle": "How the tutor should evaluate speaking output",
  "xpRewardMultiplier": 1.2,
  "reason": "Explain the psychological reasoning for this choice based on user profiles."
}
''';

    final String prompt = '''
User profile:
- Role: ${progress.role}
- Native language: ${progress.nativeLanguage}
- Streak days: ${progress.streakDays}
- Completed lessons: $lessonsCount
- Completed quizzes: $quizzesCount
- Coins: $coins
''';

    Map<String, dynamic>? geminiResult;
    try {
      geminiResult = await ModelRouter.instance.queryStructuredJson(
        systemInstruction: systemInstruction,
        prompt: prompt,
      );
    } catch (_) {}

    TutorPersonaProfile profile;
    String reason = 'Offline fallback rule configuration';

    if (geminiResult != null) {
      profile = TutorPersonaProfile(
        styleName: geminiResult['styleName'] as String? ?? 'Balanced & Competitive',
        instructionGuideline: geminiResult['instructionGuideline'] as String? ?? 'Steady progression of sentence lengths.',
        feedbackStyle: geminiResult['feedbackStyle'] as String? ?? 'Provide balanced feedback highlighting natural speaking style.',
        xpRewardMultiplier: (geminiResult['xpRewardMultiplier'] as num?)?.toDouble() ?? 1.2,
      );
      reason = geminiResult['reason'] as String? ?? 'Gemini reasoning logic.';
    } else {
      // Determine user type fallback
      if (lessonsCount > 10 && quizzesCount > 5 && coins > 200) {
        profile = TutorPersonaProfile(
          styleName: 'Challenging & Fast',
          instructionGuideline: 'Use advanced Kannada vocabulary. Give users speaking challenges with longer sentences. Throw unexpected/surprise conversational twists. Focus on quick thinking.',
          feedbackStyle: 'Give direct, high-value grammar corrections and encourage alternatives to speak like a native. Award extra points for correctness.',
          xpRewardMultiplier: 1.3,
        );
      } else if (progress.level == 'None' || lessonsCount < 3) {
        profile = TutorPersonaProfile(
          styleName: 'Slow & Friendly',
          instructionGuideline: 'Use very basic, daily survival Kannada phrases. Keep sentences short. Avoid complex grammatical structures. Translate everything clearly.',
          feedbackStyle: 'Keep corrections extremely gentle. Praise their attempt first before suggesting correct pronunciation or alternatives.',
          xpRewardMultiplier: 1.0,
        );
      } else if (progress.role.toLowerCase().contains('tourist') || progress.role.toLowerCase().contains('travel')) {
        profile = TutorPersonaProfile(
          styleName: 'Encouraging & Practical',
          instructionGuideline: 'Focus on highly practical everyday survival dialogues. Use phonetic guides heavily. Encourage using key words even if grammar is imperfect.',
          feedbackStyle: 'Praise their confidence. Correct only critical errors that prevent understanding. Focus on communication success.',
          xpRewardMultiplier: 1.1,
        );
      } else {
        profile = TutorPersonaProfile(
          styleName: 'Balanced & Competitive',
          instructionGuideline: 'Maintain a steady progression of sentence lengths. Offer contextual quizzes. Balance vocabulary acquisition with conversational practice.',
          feedbackStyle: 'Provide balanced feedback highlighting spelling, correctness, and natural speaking style.',
          xpRewardMultiplier: 1.2,
        );
      }
    }

    final updatedMetrics = Map<String, dynamic>.from(state.learningMetrics);
    updatedMetrics['active_tutor_style'] = profile.styleName;
    updatedMetrics['xp_multiplier'] = profile.xpRewardMultiplier;

    final updatedCustom = Map<String, dynamic>.from(state.customData);
    updatedCustom['tutor_instruction'] = profile.instructionGuideline;
    updatedCustom['tutor_feedback_style'] = profile.feedbackStyle;
    updatedCustom['tutor_persona_reason'] = reason;

    return state.copyWith(
      learningMetrics: updatedMetrics,
      customData: updatedCustom,
    );
  }
}
