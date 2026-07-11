import 'agent_state.dart';
import 'model_router.dart';

class LearningScienceAgent {
  static final LearningScienceAgent instance = LearningScienceAgent._internal();
  LearningScienceAgent._internal();

  Future<AgentState> process(AgentState state) async {
    final progress = state.userProfile;
    final completedCount = progress.lessonsCompletedCount;

    // Load active weak words (e.g. from state metrics or offline assets)
    final List<String> weakWords = List<String>.from(state.learningMetrics['weak_words'] ?? []);
    
    // Simulate/Retrieve historical recalls
    final Map<String, dynamic> sm2Data = Map<String, dynamic>.from(state.customData['sm2_data'] ?? {});

    // For each weak word, compute or initialize SM-2 parameters:
    // EF (Ease Factor), Interval (days), Repetition Number (n)
    final List<String> spacedRepetitionWords = [];
    for (final word in weakWords) {
      final wordData = Map<String, dynamic>.from(sm2Data[word] ?? {
        'ef': 2.5,
        'interval': 1,
        'repetition': 0,
        'lastSeen': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      });

      // Simple offline SM-2 formula simulation:
      // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      // For fallback calculations, assume quality score q = 3 (average quality)
      double ef = (wordData['ef'] as num?)?.toDouble() ?? 2.5;
      int repetition = (wordData['repetition'] as num?)?.toInt() ?? 0;
      int interval = (wordData['interval'] as num?)?.toInt() ?? 1;

      const int q = 3; 
      ef = ef + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (ef < 1.3) ef = 1.3;

      if (repetition == 0) {
        interval = 1;
      } else if (repetition == 1) {
        interval = 6;
      } else {
        interval = (interval * ef).round();
      }
      repetition += 1;

      wordData['ef'] = ef;
      wordData['interval'] = interval;
      wordData['repetition'] = repetition;
      wordData['lastSeen'] = DateTime.now().toIso8601String();

      sm2Data[word] = wordData;
      spacedRepetitionWords.add(word);
    }

    // Define System Instruction
    const String systemInstruction = '''
You are the LearningScienceAgent in an Agentic AI Kannada learning app.
Analyze the user's progress and streak metrics to adjust difficulty and spaced repetition topics.
Enforce the SuperMemo-2 (SM-2) spaced repetition pedagogical parameters.
Return a structured JSON reasoning payload matching this schema:
{
  "difficultyCoefficient": 1.0, // double (0.5 to 2.0)
  "activeRecallTopics": ["basics", "travel"],
  "spacedRepetitionWords": ["Namaskara", "Yelli"],
  "reason": "Explain the pedagogical science behind this choice based on forgetting curve parameters."
}
''';

    final String prompt = '''
User profile:
- Completed lessons: $completedCount
- Streak days: ${progress.streakDays}
- Level: ${progress.level}
- Target active recall words: $spacedRepetitionWords
''';

    Map<String, dynamic>? geminiResult;
    try {
      geminiResult = await ModelRouter.instance.queryStructuredJson(
        systemInstruction: systemInstruction,
        prompt: prompt,
      );
    } catch (_) {}

    double baseDifficulty = 1.0;
    List<String> recallTopics = [];
    String reason = 'Offline fallback SM-2 spaced repetition scheduled successfully.';

    if (geminiResult != null) {
      baseDifficulty = (geminiResult['difficultyCoefficient'] as num?)?.toDouble() ?? 1.0;
      recallTopics = List<String>.from(geminiResult['activeRecallTopics'] ?? []);
      // merge offline list with model targets
      final geminiWords = List<String>.from(geminiResult['spacedRepetitionWords'] ?? []);
      for (final w in geminiWords) {
        if (!spacedRepetitionWords.contains(w)) {
          spacedRepetitionWords.add(w);
        }
      }
      reason = geminiResult['reason'] as String? ?? 'Gemini cognitive science reasoning.';
    } else {
      // Simple rule-based forgetting curve calculation fallback
      if (completedCount >= 5) {
        recallTopics.add('basics');
        if (!spacedRepetitionWords.contains('Namaskara')) spacedRepetitionWords.add('Namaskara');
      }
      if (completedCount >= 10) {
        recallTopics.add('travel');
        if (!spacedRepetitionWords.contains('Yelli')) spacedRepetitionWords.add('Yelli');
      }

      if (progress.streakDays > 7) {
        baseDifficulty = 1.3;
      } else if (progress.streakDays < 3) {
        baseDifficulty = 0.9;
      }
    }

    // Determine CEFR level
    String cefrLevel = 'Level 0: Silent Beginner';
    if (completedCount >= 30) {
      cefrLevel = 'Level 3: Confident Speaker';
    } else if (completedCount >= 15) {
      cefrLevel = 'Level 2: Daily Communicator';
    } else if (completedCount >= 5) {
      cefrLevel = 'Level 1: Survival Speaker';
    }

    final updatedMetrics = Map<String, dynamic>.from(state.learningMetrics);
    updatedMetrics['active_recall_topics'] = recallTopics;
    updatedMetrics['spaced_repetition_words'] = spacedRepetitionWords;
    updatedMetrics['difficulty_coefficient'] = baseDifficulty;

    final updatedCustom = Map<String, dynamic>.from(state.customData);
    updatedCustom['learning_science_reason'] = reason;
    updatedCustom['sm2_data'] = sm2Data;

    return state.copyWith(
      userProfile: progress.copyWith(cefrLevel: cefrLevel),
      learningMetrics: updatedMetrics,
      customData: updatedCustom,
    );
  }
}
