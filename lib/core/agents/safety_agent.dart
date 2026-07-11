import 'package:flutter/foundation.dart';
import '../../models/lesson.dart';
import 'agent_state.dart';
import 'model_router.dart';
import '../database/curriculum_generator.dart';

class SafetyAgent {
  static final SafetyAgent instance = SafetyAgent._internal();
  SafetyAgent._internal();

  Future<AgentState> process(AgentState state, int day) async {
    final lesson = state.currentLesson;
    if (lesson == null) return state;

    // 1. Local Structural Verification Checks (First defense)
    bool isLocallyValid = true;
    if (lesson.title.trim().isEmpty || lesson.situationDescription.trim().isEmpty) {
      isLocallyValid = false;
    }
    if (lesson.vocabulary.length < 2 || lesson.dialogue.isEmpty || lesson.quiz.isEmpty) {
      isLocallyValid = false;
    }
    for (final q in lesson.quiz) {
      if (q.options.isEmpty || !q.options.contains(q.correctAnswer)) {
        isLocallyValid = false; // quiz doesn't contain the correct answer option!
      }
    }

    if (!isLocallyValid) {
      debugPrint("SafetyAgent: Local structural checks failed. Reverting to fallback lesson.");
      return state.copyWith(
        currentLesson: CurriculumGenerator.getRawLessonForDay(day),
      );
    }

    // 2. LLM Verification Layer (Semantic check)
    final String systemInstruction = '''
You are the SafetyAgent in an Agentic AI language learning platform.
Audit the correctness, safety, and quality of the proposed Kannada lesson.
Perform a 4-dimension quality audit score:
1. Usefulness: Is this highly practical for everyday life? (Score 1 to 10)
2. Naturalness: Does it sound like real-world conversational Bengaluru Kannada rather than textbook dry Kannada? (Score 1 to 10)
3. Difficulty Match: Is the syntax level correctly matched? (Score 1 to 10)
4. Cultural Accuracy: Does it reflect appropriate social contexts (elders vs friends)? (Score 1 to 10)

Respond strictly in this JSON format:
{
  "usefulness": 9, 
  "naturalness": 10,
  "difficultyMatch": 9,
  "culturalAccuracy": 10,
  "isSafe": true, 
  "reason": "Detail audit reviews here."
}
''';

    final String prompt = '''
Lesson contents to check:
Title: ${lesson.title}
Subtitle: ${lesson.subtitle}
Situation: ${lesson.situationDescription}
Vocabulary: ${lesson.vocabulary.map((v) => '${v.kannada} -> ${v.english}').join(', ')}
Dialogue turns: ${lesson.dialogue.map((d) => '${d.speaker}: ${d.textKannada}').join(' | ')}
''';

    Map<String, dynamic>? validationResult;
    try {
      validationResult = await ModelRouter.instance.queryStructuredJson(
        systemInstruction: systemInstruction,
        prompt: prompt,
      );
    } catch (_) {}

    if (validationResult != null) {
      final int usefulness = validationResult['usefulness'] as int? ?? 10;
      final int naturalness = validationResult['naturalness'] as int? ?? 10;
      final int difficultyMatch = validationResult['difficultyMatch'] as int? ?? 10;
      final int culturalAccuracy = validationResult['culturalAccuracy'] as int? ?? 10;
      final bool isSafe = validationResult['isSafe'] as bool? ?? true;

      final double avgScore = (usefulness + naturalness + difficultyMatch + culturalAccuracy) / 4.0;
      debugPrint("SafetyAgent Audit: Avg Score = $avgScore/10, Safe = $isSafe, Reason: ${validationResult['reason']}");

      if (!isSafe || avgScore < 9.0) {
        debugPrint("SafetyAgent: Low quality average score ($avgScore/10). Reverting to fallback static lesson.");
        return state.copyWith(
          currentLesson: CurriculumGenerator.getRawLessonForDay(day),
        );
      }
    }

    return state;
  }
}
