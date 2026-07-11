import 'agent_state.dart';
import 'model_router.dart';

class RetentionAgent {
  static final RetentionAgent instance = RetentionAgent._internal();
  RetentionAgent._internal();

  /// Generates a highly personalized, context-aware motivational reminder.
  /// Example: "Krishna, tomorrow you have college. Learn 5 Kannada lines to talk confidently with classmates."
  Future<String> generateMotivation(AgentState state) async {
    final progress = state.userProfile;
    final role = progress.role;
    final motivation = progress.motivation;
    final username = progress.name.isEmpty ? 'Explorer' : progress.name;
    final streak = progress.streakDays;

    final String systemInstruction = '''
You are the RetentionAgent in a Kannada language learning companion.
Your goal is to write a short, highly engaging, personalized notification/motivation sentence to encourage the user to complete their daily study session.
Do NOT output general advice.
Reference the user's role, their native language comparison if helpful, or their target life goals, and keep it under 2 sentences.

Example output:
"Krishna, tomorrow you have college. Learn 5 Kannada lines to talk confidently with classmates."
''';

    final String prompt = '''
Username: $username
Role: $role
Motivations/Goals: $motivation
Current Streak: $streak days
Generate the retention reminder message.
''';

    final bool isOnline = progress.xp > 0;
    if (isOnline) {
      try {
        final Map<String, dynamic>? jsonResult = await ModelRouter.instance.queryStructuredJson(
          systemInstruction: systemInstruction,
          prompt: prompt,
        );
        if (jsonResult != null && jsonResult['motivation'] != null) {
          return jsonResult['motivation'] as String;
        }
      } catch (_) {}
    }

    // Fallback motivating messages
    if (role.toLowerCase().contains('student')) {
      return '$username, ready to make new friends at college? Practice 5 quick hostel conversations today!';
    } else if (role.toLowerCase().contains('professional') || role.toLowerCase().contains('work')) {
      return 'Hey $username, got office meetings today? Learn 5 key office phrases to sync confidently!';
    } else {
      return 'Hi $username, don\'t break your $streak-day streak! Learn how to hail an auto in Bengaluru today.';
    }
  }
}
