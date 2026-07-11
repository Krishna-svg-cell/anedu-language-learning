import 'package:flutter/foundation.dart';
import '../../models/user_progress.dart';
import '../../models/lesson.dart';
import 'agent_state.dart';
import 'tutor_persona_agent.dart';
import 'learning_science_agent.dart';
import 'situation_generator_agent.dart';
import 'content_agent.dart';
import 'safety_agent.dart';

class SupervisorAgent {
  static final SupervisorAgent instance = SupervisorAgent._internal();
  SupervisorAgent._internal();

  /// Formulates, generates, checks, and validates the complete personalized lesson object.
  Future<Lesson> generateLessonForDay(int day, UserProgress progress) async {
    debugPrint("SupervisorAgent: Launching coordination flow for Day $day...");

    // 1. Initialize empty AgentState with user progress
    AgentState state = AgentState(userProfile: progress);

    try {
      // 2. Persona adaptation step
      state = await TutorPersonaAgent.instance.process(state);

      // 3. Learning science calculations step
      state = await LearningScienceAgent.instance.process(state);

      // 4. Outline generation step
      state = await SituationGeneratorAgent.instance.process(state, day);

      // 5. Complete lesson items generation step
      state = await ContentAgent.instance.process(state, day);

      // 6. Safety check verification step
      state = await SafetyAgent.instance.process(state, day);

      debugPrint("SupervisorAgent: Pipeline successful. Verified Lesson Generated.");
      return state.currentLesson!;
    } catch (e) {
      debugPrint("SupervisorAgent Exception: $e. Reverting pipeline to fallback templates.");
      // Instantly falls back to local rule-based cached content templates to prevent crashes
      final fallback = state.currentLesson;
      if (fallback != null) return fallback;
      
      // Complete safety fallback from static curriculum generator
      return Lesson(
        id: 'day_$day',
        title: 'Daily Practice',
        subtitle: 'Revise everyday Kannada phrases.',
        category: LessonCategory.basics,
        situationDescription: 'Join Mittu for a short daily review challenge to reinforce your Kannada speaking skills.',
        vocabulary: [],
        dialogue: [],
        quiz: [],
        sentenceBuilderWords: ['Namaskara'],
        sentenceBuilderAnswer: 'Namaskara',
        sentenceBuilderTranslation: 'Hello',
        missionDescription: 'Practice saying Namaskara to someone.',
        isUnlocked: true,
      );
    }
  }
}
