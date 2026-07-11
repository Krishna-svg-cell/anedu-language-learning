import 'agent_state.dart';
import 'model_router.dart';
import 'rag_knowledge_base.dart';

class SituationGeneratorAgent {
  static final SituationGeneratorAgent instance = SituationGeneratorAgent._internal();
  SituationGeneratorAgent._internal();

  Future<AgentState> process(AgentState state, int day) async {
    final progress = state.userProfile;
    final role = progress.role;
    final targetGoal = state.currentGoal.isNotEmpty ? state.currentGoal : progress.motivation;
    
    // Time of day detection
    final hour = DateTime.now().hour;
    String timeContext = 'Daytime';
    if (hour >= 5 && hour < 12) timeContext = 'Morning';
    else if (hour >= 12 && hour < 17) timeContext = 'Afternoon';
    else if (hour >= 17 && hour < 22) timeContext = 'Evening';
    else timeContext = 'Night';

    // RAG check: Fetch linked cultural/grammar items
    final category = _getCategoryForDay(day);
    final ragResults = RAGKnowledgeBase.query(category);
    final String ragReference = ragResults.isNotEmpty ? ragResults[0].content : '';
    final String languageBridge = RAGKnowledgeBase.getLanguageBridgeAdvice(progress.level, category);

    // Prompt construction for Situation Generation
    final String systemInstruction = '''
You are the SituationGeneratorAgent in an Agentic AI Kannada learning app.
Your task is to outline a highly personalized daily situation and learning structure for the user.
ANEDU does NOT generate isolated, random lessons. Every situation must build part of a 6-stage real-world survival journey:
1. Entering/Greetings
2. Excusing/Calling attention
3. Examining Menu/Price options
4. Detailed Ordering/Requests
5. Problem handling/Unexpected changes (Negotiation/Traffic adjustments)
6. Payments/UPI checkout

Based on the chronological day parameter, select the correct journey stage and outline the lesson.
The output MUST strictly match the following JSON schema:
{
  "situation": "A concise title, e.g. 'Cafe Ordering - Step 3: Check Menu'",
  "difficulty": "Beginner, Intermediate, or Advanced based on metrics.",
  "vocabulary": ["4 essential daily survival words"],
  "dialogues": ["Description of what character Ramesh (colleague/waiter/driver) asks and what user answers"],
  "missions": ["An actionable real-world challenge to execute outside today"]
}
''';

    final String prompt = '''
User profile facts:
- Role: $role
- Motivation/Goal: $targetGoal
- Visited Places: ${progress.visitedPlaces.join(', ')}
- Native Language / Target Help: $languageBridge
- Context Time: $timeContext
- Day in timeline: Day $day
- RAG Knowledge Base guide: $ragReference

Generate a highly relevant, custom situation outline tailored to these parameters. Keep it practical.
''';

    // Query structured JSON
    Map<String, dynamic>? outline;
    final bool isOnline = progress.xp > 0; // standard indicator or network check. We can call ModelRouter.
    if (isOnline) {
      outline = await ModelRouter.instance.queryStructuredJson(
        systemInstruction: systemInstruction,
        prompt: prompt,
      );
    }

    // Offline / Fallback outline if online query fails or user is offline
    if (outline == null) {
      outline = _generateFallbackOutline(day, role, targetGoal, timeContext);
    }

    final updatedCustom = Map<String, dynamic>.from(state.customData);
    updatedCustom['situation_outline'] = outline;
    updatedCustom['current_category'] = category;
    updatedCustom['language_bridge_note'] = languageBridge;
    updatedCustom['rag_reference_used'] = ragReference;

    return state.copyWith(
      customData: updatedCustom,
    );
  }

  String _getCategoryForDay(int day) {
    if (day <= 15) return 'greetings';
    if (day <= 30) return 'travel';
    if (day <= 45) return 'restaurant';
    if (day <= 60) return 'shopping';
    if (day <= 75) return 'college';
    return 'basics';
  }

  Map<String, dynamic> _generateFallbackOutline(int day, String role, String goal, String timeContext) {
    final lowerGoal = goal.toLowerCase();
    if (lowerGoal.contains('interview')) {
      return {
        'situation': 'Emergency path - Step $day: Quick Interview Preparation',
        'difficulty': 'Intermediate',
        'vocabulary': ['internship', 'project', 'introduce', 'details'],
        'dialogues': ['Introduce academic project details in Kannada', 'Respond to senior interviewer questions'],
        'missions': ['Introduce your background to one peer in Kannada today']
      };
    } else if (lowerGoal.contains('hospital') || lowerGoal.contains('doctor')) {
      return {
        'situation': 'Emergency path - Step $day: Visiting a Doctor',
        'difficulty': 'Beginner',
        'vocabulary': ['pain', 'fever', 'medicine', 'tablet'],
        'dialogues': ['Explain symptoms to clinic receptionist', 'Ask doctor for correct tablet timings'],
        'missions': ['Learn three body pain descriptors in Kannada']
      };
    } else if (lowerGoal.contains('date') || lowerGoal.contains('friend')) {
      return {
        'situation': 'Emergency path - Step $day: Going on a Coffee Date',
        'difficulty': 'Intermediate',
        'vocabulary': ['coffee', 'hobbies', 'meet', 'beautiful'],
        'dialogues': ['Greet partner politely at cafe table', 'Discuss weekend hobbies and interests'],
        'missions': ['Compliment someone using Kannada greetings']
      };
    }

    final lowerRole = role.toLowerCase();
    if (lowerRole.contains('student')) {
      return {
        'situation': 'Hostel Roommate Introduction ($timeContext)',
        'difficulty': 'Beginner',
        'vocabulary': ['roommate', 'hostel', 'study', 'class'],
        'dialogues': ['Greet roommate in hostel room', 'Ask about morning class schedule'],
        'missions': ['Greet a classmate with a friendly Namaskara today']
      };
    } else if (lowerRole.contains('professional') || lowerRole.contains('work')) {
      return {
        'situation': 'Quick Office Cafeteria Sync ($timeContext)',
        'difficulty': 'Beginner',
        'vocabulary': ['office', 'colleague', 'meeting', 'tea'],
        'dialogues': ['Meet coworker at water cooler', 'Suggest going out for hot tea'],
        'missions': ['Ask a coworker if they would like to have tea in Kannada']
      };
    } else {
      return {
        'situation': 'Hailing an Auto rickshaw ($timeContext)',
        'difficulty': 'Beginner',
        'vocabulary': ['auto', 'destination', 'fare', 'stop'],
        'dialogues': ['Call auto driver near street', 'Ask price to target location'],
        'missions': ['Ask an auto driver "Eshtu?" (how much) for a destination']
      };
    }
  }
}
