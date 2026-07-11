import 'dart:math';
import '../../models/lesson.dart';
import '../../models/user_progress.dart';
import '../database/curriculum_generator.dart';
import 'agent_state.dart';
import 'model_router.dart';

class ContentAgent {
  static final ContentAgent instance = ContentAgent._internal();
  ContentAgent._internal();

  Future<AgentState> process(AgentState state, int day) async {
    final progress = state.userProfile;
    final outline = state.customData['situation_outline'] as Map<String, dynamic>? ?? {};
    final categoryStr = state.customData['current_category'] as String? ?? 'basics';
    
    final String situation = outline['situation'] ?? 'Kannada Conversation';
    final List<dynamic> vocabOutline = outline['vocabulary'] ?? [];
    final List<dynamic> dialoguesOutline = outline['dialogues'] ?? [];

    final String systemInstruction = '''
You are the ContentAgent in an Agentic AI Kannada learning app.
Your task is to generate complete, high-fidelity lesson contents matching the following JSON schema:
{
  "title": "A short, engaging lesson title, e.g., 'Coffee at Darshini'",
  "subtitle": "A helpful explanation of what is taught, e.g., 'Learn to order hot drinks.'",
  "situationDescription": "A hook story introduction setting the scene, establishing the user as the main character (e.g. 'You just arrived in Majestic station, Bengaluru. You carry two bags...').",
  "vocabulary": [
    {
      "id": "v_1",
      "kannada": "Ondu",
      "english": "One",
      "pronunciation": "Ohn-doo",
      "exampleSentenceKannada": "Ondu coffee kodi.",
      "exampleSentenceEnglish": "Give me one coffee.",
      "category": "numbers"
    }
  ],
  "dialogue": [
    {
      "speaker": "Ramesh (Waiter)",
      "textKannada": "Namaskara! Masala dosa fresh ide, enu beku?",
      "textEnglish": "Hello! Masala dosa is fresh, what would you like?",
      "pronunciation": "Namaskara! Masala dosa fresh ee-deh, ay-noo bay-koo?",
      "isUser": false
    },
    {
      "speaker": "User",
      "textKannada": "Ondu filter kapi kodi.",
      "textEnglish": "Give one filter coffee.",
      "pronunciation": "Ohn-doo filter kapi koh-dee.",
      "isUser": true
    }
  ],
  "quiz": [
    {
      "id": "q_1",
      "questionText": "What does 'beda' mean in context of sugar?",
      "options": ["Want", "Don't want", "Fresh", "More"],
      "correctAnswer": "Don't want",
      "type": "mcq"
    }
  ],
  "sentenceBuilderWords": ["kodi", "kapi", "filter", "Ondu"],
  "sentenceBuilderAnswer": "Ondu filter kapi kodi.",
  "sentenceBuilderTranslation": "Give one filter coffee.",
  "missionDescription": "Try ordering coffee using 'kodi' at your local cafe.",
  "grammarBites": [
    "Textbook vs Daily comparison: e.g. Textbook: 'Neevu ellige hoguttiddiri?' vs Daily: 'Yelli hogtiddira?'. Provide direct explanations of both.",
    "Language Bridge: comparative analogies tailored specifically to the user's native language comparisons.",
    "Respectful rules: explaining when to say something respectfully vs casually (e.g. elders vs roommates).",
    "Alternative Replies: list multiple other ways to reply in this dialogue scenario (e.g. 'going to office', 'going to class', 'going home')."
  ]
}

Ensure all dialogues are short (2 to 4 turns) and use natural local phrasing. Ensure vocabulary count is exactly 4. Ensure quiz count is exactly 4. Ensure sentenceBuilderWords can form the exact sentenceBuilderAnswer.
''';

    final String prompt = '''
Generate a lesson for Day $day.
Timeline Category: $categoryStr
Personalized Situation Outline: $situation
Vocabulary hints to include: ${vocabOutline.join(', ')}
Dialogue context: ${dialoguesOutline.join(' -> ')}
Learner: ${progress.name} (${progress.role})
Native language bridge context: ${state.customData['language_bridge_note'] ?? ''}
RAG context: ${state.customData['rag_reference_used'] ?? ''}
Tutor personalization instruction: ${state.customData['tutor_instruction'] ?? ''}
''';

    Map<String, dynamic>? lessonJson;
    final bool isOnline = progress.xp > 0; // indicates online/offline capability
    if (isOnline) {
      lessonJson = await ModelRouter.instance.queryStructuredJson(
        systemInstruction: systemInstruction,
        prompt: prompt,
      );
    }

    Lesson finalLesson;
    if (lessonJson != null) {
      try {
        // Enforce fields
        lessonJson['id'] = 'day_$day';
        lessonJson['category'] = categoryStr;
        lessonJson['xpReward'] = (20 * (state.learningMetrics['xp_multiplier'] as double? ?? 1.0)).round();
        lessonJson['coinReward'] = 15;
        lessonJson['isUnlocked'] = true;
        lessonJson['isCompleted'] = false;
        
        finalLesson = Lesson.fromJson(lessonJson);
      } catch (e) {
        // Parse fallback if schema parsing fails
        finalLesson = CurriculumGenerator.getRawLessonForDay(day);
      }
    } else {
      // Fallback to static rule curriculum if offline
      finalLesson = CurriculumGenerator.getRawLessonForDay(day);
    }

    return state.copyWith(
      currentLesson: finalLesson,
    );
  }
}
